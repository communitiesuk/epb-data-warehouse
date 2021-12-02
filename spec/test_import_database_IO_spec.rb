require "parallel"

RSpec.describe "Test load times of copy import" do
  let(:xml) do
    Samples.xml("RdSAP-Schema-20.0.0")
  end

  def valid_json?(input)
    JSON.parse(input)
    true
  rescue StandardError
    false
  end

  def parse_xml(xml, id)
    certificate = Parallel.map([0]) { |_|
      export_config = XmlPresenter::Rdsap::Rdsap20ExportConfiguration.new
      parser = XmlPresenter::Parser.new(**export_config.to_args(sub_node_value: id))
      parser.parse(xml)
    }.first

    certificate["schema_type"] = "RdSAP-Schema-20.0.0"
    certificate["assessment_address_id"] = "124895312"
    certificate["created_at"] = Time.now
    certificate
  end

  def alter_table(logged = true)
    sql = if logged
            <<-SQL
          ALTER TABLE assessment_attribute_values SET UNLOGGED
            SQL
          else
            <<-SQL
        ALTER TABLE assessment_attribute_values SET LOGGED
            SQL
          end

    ActiveRecord::Base.connection.exec_query(sql)
  end

  def update_indexes(drop = true)
    sql = if drop
            <<-SQL
          DROP INDEX index_assessment_attribute_values_on_assessment_id, index_assessment_attribute_values_on_attribute_id, index_assessment_attribute_values_on_attribute_value, index_assessment_id_attribute_id_on_aav
            SQL
          else
            <<-SQL
        CREATE INDEX <index_name> ON <target_table>(column1, …,column n)
            SQL
          end

    ActiveRecord::Base.connection.exec_query(sql)
  end

  def attribute_value_int(attribute_value)
    within_integer_range?(attribute_value) ? attribute_value.to_i : nil
  rescue StandardError
    nil
  end

  def attribute_value_float(attribute_value)
    attribute_value.to_f.zero? ? nil : attribute_value.to_f
  rescue StandardError
    nil
  end

  def within_integer_range?(number)
    (["0", 0, 0.0].include?(number) || !number.to_i.zero?) && number.to_i < ((2**32) - 1) && number.to_i > -(2**32)
  end

  def create_insert(assessment_id, hash, attributes)
    sql = "INSERT INTO assessment_attribute_values(assessment_id, attribute_id, attribute_value, attribute_value_int, attribute_value_float, json )  VALUES"
    values_array = []
    hash.each do |item|
      id = get_attribute_id(item[0], attributes)
      unless id.nil?
        values_array << set_insert_value(assessment_id, id, item[1])
      end
    end
    sql += values_array.join(",")

    ActiveRecord::Base.connection.exec_query(sql)
  rescue ActiveRecord::StatementInvalid => e
    pp sql
    pp e.message
    nil
  end

  def set_insert_value(assessment_id, id, attribute_value)
    if attribute_value.respond_to?(:to_h)
      json_value = attribute_value
      attribute_value = "null"
    else
      attribute_int = attribute_value_int(attribute_value)
      attribute_float = attribute_value_float(attribute_value)
    end

    if attribute_int.nil?
      attribute_int = "null"
    end

    if attribute_float.nil?
      attribute_float = "null"
    end

    json_value = if json_value.nil?
                   "null"
                 else
                   "cast('#{json_value.to_json}' AS json)"
                 end

    "('#{assessment_id}', #{id},  '#{attribute_value}', #{attribute_int}, #{attribute_float},  #{json_value} )"
  end

  def get_attribute_id(attribute_name, ids)
    ids.find { |i| i["attribute_name"] == attribute_name }["attribute_id"]
  rescue NoMethodError
    nil
  end

  def update_foreign_key(drop = true)
    if drop
      ActiveRecord::Base.connection.exec_query("ALTER TABLE assessment_attribute_values DROP CONSTRAINT fk_attribute_id")
    else
      ActiveRecord::Base.connection.exec_query("ALTER TABLE assessment_attribute_values ADD CONSTRAINT fk_attribute_id FOREIGN KEY (attribute_id)
        REFERENCES assessment_attributes (attribute_id) ")
    end
  end

  def save_attributes(attributes)
    sql = "INSERT INTO assessment_attributes(attribute_name,parent_name ) VALUES "
    values_array = []
    attributes.each { |i| values_array << " ('#{i}', '') " }
    sql += values_array.join(",")
    sql += "ON CONFLICT (attribute_name,parent_name )  DO UPDATE SET attribute_id=EXCLUDED.attribute_id, attribute_name=EXCLUDED.attribute_name
RETURNING attribute_id, attribute_name "
    ActiveRecord::Base.connection.exec_query(sql)
  end

  it "sets the table to be unlogged before import" do
    expect { alter_table }.not_to raise_error
  end

  it "sets the table to be logged after import" do
    expect { alter_table(false) }.not_to raise_error
  end

  it "creates an array of ids based on the attributes to be added" do
    expect { save_attributes(parse_xml(xml, "0000-0000-0000-0000-0001").keys) }.not_to raise_error
  end

  it "creates an a single insert cmd for the whole hash" do
    attributes = save_attributes(parse_xml(xml, "0000-0000-0000-0000-0001").keys)
    expect { create_insert("0000-0000-0000-0000-0001", parse_xml(xml, "0000-0000-0000-0000-0001"), attributes) }.not_to raise_error
  end

  context "test the time for saving 10 RdSAP" do
    before do
      documents_gateway = Gateway::DocumentsGateway.new
      certificate = parse_xml(xml, "0000-0000-0000-0000-0001")
      # update_foreign_key
      10.times do |n|
        attributes = save_attributes(parse_xml(xml, "0000-0000-0000-0000-0001").keys)
        assessment_id = "0000-0000-0000-0000-000#{n}"
        documents_gateway.add_assessment(assessment_id: assessment_id, document: certificate)
        create_insert(assessment_id, certificate, attributes)
      end
      # update_foreign_key(false)
    end

    # after do
    #   update_foreign_key(false)
    # end

    it "runs the test with logged table" do
      expect(1).to eq(1)
    end

    it "runs the test without a logging on the table" do
      alter_table
      expect(1).to eq(1)
    end
  end

  context "test the existing db speed" do
    before do
      use_case = UseCase::ImportCertificateData.new(assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, documents_gateway: Gateway::DocumentsGateway.new)
      certificate = parse_xml(xml, "0000-0000-0000-0000-0001")
      10.times do |n|
        use_case.execute(assessment_id: "0000-0000-0000-0000-000#{n}", certificate_data: certificate)
      end
    end

    it "runs the test with logged table" do
      expect(1).to eq(1)
    end
  end
end

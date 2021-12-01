RSpec.describe "Test load times of copy import" do
  let(:xml) do
    Samples.xml("RdSAP-Schema-20.0.0")
  end

  def parse_xml(xml, id)
    export_config = XmlPresenter::Rdsap::Rdsap20ExportConfiguration.new
    parser = XmlPresenter::Parser.new(**export_config.to_args(sub_node_value: id))
    certificate = parser.parse(xml)

    certificate["schema_type"] = "RdSAP-Schema-20.0.0"
    certificate["assessment_address_id"] = "meta_data[:assessmentAddressId]"
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

  def create_insert(assessment_id, hash, attributes)
    sql = "INSERT INTO assessment_attribute_values(assessment_id, attribute_id, attribute_value)  VALUES"
    values_array = []
    hash.each do |item|
      id =  get_attribute_id(item[0], attributes)
      unless id.nil?
        values_array << "('#{assessment_id}', #{id},  '#{item[1]}' )"
      end
    end
    sql += values_array.join(",")

    ActiveRecord::Base.connection.exec_query(sql)
  end

  def get_attribute_id(attribute_name, ids)
    ids.find { |i| i["attribute_name"] == attribute_name }["attribute_id"]
  rescue NoMethodError
    nil
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

  it "sets the table to be unloggded before import" do
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
      attributes = save_attributes(parse_xml(xml, "0000-0000-0000-0000-0001").keys)
      certificate =  parse_xml(xml, "0000-0000-0000-0000-0001")
      10.times { |n|
        create_insert("0000-0000-0000-0000-000#{n}", certificate, attributes)
      }
    end

    it 'runs the test with logged table' do
      expect(1).to eq(1)
    end

    it 'runs the test without a logging on the table' do
      alter_table
      expect(1).to eq(1)
    end
  end

end

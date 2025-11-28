shared_context "when testing fn_sum_attribute_values" do
  def sum_attribute_values_call(attributes)
    attr_string = attributes.map { |a| connection.quote(a) }.join(",")
    sql = "SELECT sum_attribute_values(ARRAY[#{attr_string}], #{connection.quote(assessment_id)}) AS total"
    result = connection.exec_query(sql).first["total"]
    result.nil? ? nil : result.to_i
  end
end

describe "Create psql function to sum attribute values" do
  include_context "when testing fn_sum_attribute_values"

  let(:connection) { ActiveRecord::Base.connection }
  let(:assessment_attributes_gateway) { Gateway::AssessmentAttributesGateway.new }
  let(:attribute_values_result) do
    ActiveRecord::Base.connection.exec_query(
      "SELECT * FROM assessment_attribute_values",
    )
  end
  let(:assessment_id) { "0000-0000-0000-0000-0001" }

  before do
    ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE assessment_attributes CASCADE;")
    ActiveRecord::Base.connection.reset_pk_sequence!("assessment_attributes")
    Gateway::AssessmentAttributesGateway.reset!
    assessment_attributes_gateway.add_attribute_value(assessment_id: "0000-0000-0000-0000-0001", attribute_name: "a", attribute_value: "3")
    assessment_attributes_gateway.add_attribute_value(assessment_id: "0000-0000-0000-0000-0001", attribute_name: "b", attribute_value: "5")
  end

  context "when attributes are present" do
    it "returns the sum of the numeric values" do
      expect(sum_attribute_values_call(%w[a b])).to eq 8
    end
  end

  context "when one of the attributes is missing" do
    it "ignores missing attribute and sums present values" do
      expect(sum_attribute_values_call(%w[a missing])).to eq 3
    end
  end

  context "when none of the attributes exist" do
    it "returns nil" do
      expect(sum_attribute_values_call(%w[missing_1 missing_2])).to be_nil
    end
  end

  context "when attributes exist but have NULL values" do
    before do
      assessment_attributes_gateway.add_attribute_value(assessment_id: "0000-0000-0000-0000-0001", attribute_name: "c", attribute_value: nil)
      assessment_attributes_gateway.add_attribute_value(assessment_id: "0000-0000-0000-0000-0001", attribute_name: "d", attribute_value: nil)
    end

    it "returns nil" do
      expect(sum_attribute_values_call(%w[c d])).to be_nil
    end
  end
end

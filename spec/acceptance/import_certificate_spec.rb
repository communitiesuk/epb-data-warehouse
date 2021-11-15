describe "Acceptance::ImportCertificate" do
  subject(:usecase) do
    UseCase::ImportCertificates.new eav_gateway: Gateway::AssessmentAttributesGateway.new,
                                    certificate_gateway: certificate_gateway,
                                    queues_gateway: queues_gateway
  end

  def attributes_values_from_database(column, attribute)
    ActiveRecord::Base.connection.exec_query(
      "SELECT * FROM assessment_attribute_values WHERE #{column} = #{attribute}",
    )
  end

  let(:certificate_gateway) do
    instance_double(Gateway::RegisterApiGateway)
  end

  let(:queues_gateway) do
    Gateway::QueuesGateway.new(redis_client: redis)
  end

  let(:redis) { MockRedis.new }

  let!(:xml_sample) do
    Samples.xml("RdSAP-Schema-20.0.0")
  end

  let!(:meta_data_sample) do
    {
      "typeOfAssessment": "RdSAP",
      "optOut": false,
      "createdAt": "2021-07-21T11:26:28.045Z",
      "cancelledAt": nil,
      "notForIssueAt": nil,
      "schemaType": "RdSAP-Schema-20.0.0",
      "assessmentAddressId": "RRN-0000-0000-0000-0000-0000",
    }
  end

  let(:ids) do
    %w[0000-0000-0000-0000-0000]
  end

  after do
    redis.flushdb
  end

  before do
    allow(Gateway::RegisterApiGateway).to receive(:new).and_return(certificate_gateway)
    allow(certificate_gateway).to receive(:fetch).and_return(xml_sample)
    allow(certificate_gateway).to receive(:fetch_meta_data).and_return(meta_data_sample)
    queues_gateway.push_to_queue(:assessments, ids)
    usecase.execute
  end

  context "when an assessment id is provided to the queue" do
    it "saves the relevant attributes values to the database" do
      response = attributes_values_from_database("attribute_value", "'RdSAP-Schema-20.0.0'")
      expect(response.length).to be >= 1
    end

    it "saves the relevant json to the database" do
      response = attributes_values_from_database("json", "'{\"u_value\": 2, \"data_source\": 2, \"solar_transmittance\": 0.72}'")
      expect(response.length).to be >= 1
    end
  end

  context "when json is entered into the attribute value table" do
    it "is queryable" do
      response = ActiveRecord::Base.connection.exec_query(
        "select * from assessment_attribute_values WHERE json->>'stone_walls' like 'true'",
      )
      expect(response.length).to be >= 1
    end
  end
end

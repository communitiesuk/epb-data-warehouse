describe "Acceptance::ImportCertificate" do
  subject(:usecase) do
    UseCase::ImportCertificates.new(Gateway::AssessmentAttributesGateway.new, certificate_gateway, redis_gateway)
  end

  # let(:attribute_values) do
  #   ActiveRecord::Base.connection.exec_query(
  #     "SELECT * FROM assessment_attribute_values WHERE attribute_value = 'RdSAP-Schema-20.0.0'",
  #   )
  # end

  def attribute_values(attribute)
      ActiveRecord::Base.connection.exec_query(
        "SELECT * FROM assessment_attribute_values",
      )
  end

  let(:certificate_gateway) do
    instance_double(Gateway::RegisterApiGateway)
  end

  let(:redis_gateway) do
    Gateway::RedisGateway.new(redis_client: redis)
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
  end

  context "When an assessment id is provided to the queue" do

    before do
      redis_gateway.push_to_queue(:assessments, ids)
    end

    it "saves the relevant attributes to the database" do
      subject.execute
      json_attributes = attribute_values("'RdSAP-Schema-20.0.0'")
      # pp json_attributes
      # ruby_attributes = JSON.parse(json_attributes)
      # pp ruby_attributes
      # expect(ruby_attributes.first["attribute_value"]).to eq("RdSAP-Schema-20.0.0")
    end
  end
end

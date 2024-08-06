shared_context "when getting attributes from db" do
  def attributes_values_from_database(column, attribute)
    ActiveRecord::Base.connection.exec_query(
      "SELECT * FROM assessment_attribute_values WHERE #{column} = #{attribute}",
    )
  end
end

describe "Acceptance::ImportCertificate" do
  subject(:use_case) do
    UseCase::ImportCertificates.new import_xml_certificate_use_case:,
                                    recovery_list_gateway:,
                                    queues_gateway:
  end

  include_context "when getting attributes from db"

  let(:assessments_country_id_gateway) { instance_double(Gateway::AssessmentsCountryIdGateway) }

  let(:import_xml_certificate_use_case) do
    eav_gateway = Gateway::AssessmentAttributesGateway.new
    certificate_data_use_case = UseCase::ImportCertificateData.new(
      assessment_attribute_gateway: eav_gateway,
      documents_gateway: Gateway::DocumentsGateway.new,
      logger:,
    )
    UseCase::ImportXmlCertificate.new import_certificate_data_use_case: certificate_data_use_case,
                                      assessment_attribute_gateway: eav_gateway,
                                      certificate_gateway:,
                                      recovery_list_gateway:,
                                      assessments_country_id_gateway:
  end

  let(:certificate_gateway) do
    instance_double(Gateway::RegisterApiGateway)
  end

  let(:queues_gateway) do
    Gateway::QueuesGateway.new(redis_client: redis)
  end

  let(:recovery_list_gateway) do
    Gateway::RecoveryListGateway.new(redis_client: redis)
  end

  let(:logger) do
    logger = instance_double(Logger)
    allow(logger).to receive(:error)
    logger
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
      "countryId": 1,
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
    allow(assessments_country_id_gateway).to receive(:insert)
    use_case.execute
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

    it "saves the county_id to the assessments_country_id table" do
      # result = Gateway::AssessmentsCountryIdGateway::AssessmentsCountryId.find_by(assessment_id: ids.first)
      expect(assessments_country_id_gateway).to have_received(:insert).with(assessment_id: ids.first, country_id: 1).exactly(1).times
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

  context "when importing with data point exceeding character limit" do
    subject(:use_case) do
      UseCase::ImportCertificates.new import_xml_certificate_use_case:,
                                      recovery_list_gateway:,
                                      queues_gateway:
    end

    let(:import_xml_certificate_use_case) do
      eav_gateway = Gateway::AssessmentAttributesGateway.new
      certificate_data_use_case = UseCase::ImportCertificateData.new(
        assessment_attribute_gateway: eav_gateway,
        documents_gateway: Gateway::DocumentsGateway.new,
        logger:,
      )
      UseCase::ImportXmlCertificate.new import_certificate_data_use_case: certificate_data_use_case,
                                        assessment_attribute_gateway: eav_gateway,
                                        certificate_gateway:,
                                        recovery_list_gateway:,
                                        assessments_country_id_gateway:
    end

    let(:certificate_gateway) do
      instance_double(Gateway::RegisterApiGateway)
    end

    let(:queues_gateway) do
      Gateway::QueuesGateway.new(redis_client: redis)
    end

    let(:recovery_list_gateway) do
      Gateway::RecoveryListGateway.new(redis_client: redis)
    end

    let(:logger) do
      logger = instance_double(Logger)
      allow(logger).to receive(:error)
      logger
    end

    let(:redis) { MockRedis.new }

    let!(:xml_sample) do
      Samples.xml("CEPC-8.0.0", "dec_exceeds_character_count")
    end

    let!(:meta_data_sample) do
      {
        "typeOfAssessment": "DEC",
        "optOut": false,
        "createdAt": "2021-07-21T11:26:28.045Z",
        "cancelledAt": nil,
        "notForIssueAt": nil,
        "schemaType": "CEPC-8.0.0",
        "assessmentAddressId": "RRN-0000-0000-0000-0000-0000",
        "country_id": 1,
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
      use_case.execute
    end

    context "when an assessment id is provided to the queue for an assessment with a data point exceeding the character limit" do
      it "saves the relevant attributes values to the database" do
        response = attributes_values_from_database("assessment_id", "'0000-0000-0000-0000-0000'")
        expect(response.length).to be >= 1
      end

      it "saves the relevant content to the database" do
        response = attributes_values_from_database("attribute_value", "'Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui. Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia. Nam pretium turpis et arcu. Duis arcu tortor, suscipit eget, imperdiet nec, imperdiet iaculis, ipsum. Sed aliquam ultrices mauris. Integer ante arcu, accumsan a, consectetuer eget, posuere ut, mauris. Praesent adipiscing. Phasellus ullamcorper ipsum rutrum nunc. Nunc nonummy metus. Vestibulum volutpat pretium libero. Cras id dui. Aenean ut eros et nisl sagittis vestibulum. Nullam nulla eros, ultricies sit amet, nonummy id, imperdiet feugiat, pede. Sed lectus. Donec mollis hendrerit risus. Phasellus nec sem in justo pellentesque facilisis. Etiam imperdiet imperdiet orci. Nunc nec neque. Phasellus leo dolor, tempus non, auctor et, hendrerit quis, nisi. Curabitur ligula sapien, tincidunt non, euismod vitae, posuere imperdiet, leo. Maecenas malesuada. Praesent congue erat at massa. Sed cursus turpis vitae tortor. Donec posuere vulputate arcu. Phasellus accumsan cursus velit. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Sed aliquam, nisi...'")
        expect(response.length).to be >= 1
      end
    end

    context "when json is entered into the assessment_document table" do
      it "is queryable" do
        response = ActiveRecord::Base.connection.exec_query(
          "select * from assessment_documents where assessment_id = '0000-0000-0000-0000-0000'",
        )
        expect(response.length).to be >= 1
      end
    end
  end
end

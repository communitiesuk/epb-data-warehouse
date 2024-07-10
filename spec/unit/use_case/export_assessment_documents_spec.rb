describe UseCase::ExportAssessmentDocuments do
  let(:use_case) { described_class.new(documents_gateway:, storage_gateway:) }
  let(:documents_gateway) { instance_double Gateway::DocumentsGateway }
  let(:storage_gateway) { instance_double Gateway::StorageGateway }
  let(:assessment_documents) do
    [{
      assessment_id: "8570-6826-6530-4969-0202",
      document: {
        "schema_version_original" => "LIG-19.0",
        "sap_version" => 9.94,
        "calculation_software_name" => "Elmhurst Energy Systems RdSAP Calculator",
        "calculation_software_version" => "4.05r0005",
        "rrn" => "8570-6826-6530-4969-0202",
        "inspection_date" => "2020-06-01",
        "report_type" => 2,
        "completion_date" => "2020-06-01",
        "registration_date" => "2020-06-01",
        "status" => "entered",
        "language_code" => 1,
        "tenure" => 1,
        "transaction_type" => 1,
        "property_type" => 0,
        "property" =>
          { "address" =>
              { "address_line_1" => "25, Marlborough Place",
                "post_town" => "LONDON",
                "postcode" => "NW8 0PG" },
            "uprn" => 7_435_089_668 },
        "region_code" => 17,
        "country_code" => "EAW",
      }.to_json,
    },
     {
       assessment_id: "8570-6826-6530-4969-0203",
       document: {
         "schema_version_original" => "LIG-19.0",
         "sap_version" => 9.94,
         "calculation_software_name" => "Elmhurst Energy Systems RdSAP Calculator",
         "calculation_software_version" => "4.05r0005",
         "rrn" => "8570-6826-6530-4969-0203",
         "inspection_date" => "2020-06-01",
         "report_type" => 2,
         "completion_date" => "2020-06-01",
         "registration_date" => "2020-06-01",
         "status" => "entered",
         "language_code" => 1,
         "tenure" => 1,
         "transaction_type" => 1,
         "property_type" => 0,
         "property" =>
             { "address" =>
                 { "address_line_1" => "26, Marlborough Place",
                   "post_town" => "LONDON",
                   "postcode" => "NW8 0PG" },
               "uprn" => 7_435_089_669 },
         "region_code" => 17,
         "country_code" => "EAW",
       }.to_json,
     }]
  end

  context "when exporting documents to the S3 bucket" do
    before do
      allow(documents_gateway).to receive(:fetch_assessments_json).and_return assessment_documents
      allow(storage_gateway).to receive(:write_file).with(file_name: assessment_documents[0][:assessment_id], data: assessment_documents[0][:document])
      allow(storage_gateway).to receive(:write_file).with(file_name: assessment_documents[1][:assessment_id], data: assessment_documents[1][:document])
    end

    it "calls the gateway to fetch the redacted documents" do
      use_case.execute
      expect(documents_gateway).to have_received(:fetch_assessments_json)
    end

    it "uploads each assessment document to the S3 bucket" do
      use_case.execute
      expect(storage_gateway).to have_received(:write_file).exactly(2).times
      expect(storage_gateway).to have_received(:write_file).with(file_name: assessment_documents[0][:assessment_id], data: assessment_documents[0][:document])
      expect(storage_gateway).to have_received(:write_file).with(file_name: assessment_documents[1][:assessment_id], data: assessment_documents[1][:document])
    end
  end

  context "when there is a storage error" do
    before do
      allow(documents_gateway).to receive(:fetch_assessments_json).and_return assessment_documents
      allow(storage_gateway).to receive(:write_file).and_raise Aws::S3::Errors::ServiceError.new(Seahorse::Client::RequestContext, "something has gone wrong")
    end

    it "raises an error" do
      expect { use_case.execute }.to raise_error Aws::S3::Errors::ServiceError
    end
  end
end

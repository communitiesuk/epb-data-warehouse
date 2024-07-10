describe "ExportDocumentsRake" do
  subject(:task) { get_task("export_documents") }

  let(:storage_gateway) do
    Gateway::StorageGateway.new(bucket_name: ENV["BUCKET_NAME"], stub_responses: true)
  end

  let(:use_case) { instance_double(UseCase::ExportAssessmentDocuments) }

  before do
    ENV["BUCKET_NAME"] = "test"
    allow(Container).to receive(:storage_gateway).and_return storage_gateway
    allow(UseCase::ExportAssessmentDocuments).to receive(:new).and_return use_case
    allow(use_case).to receive(:execute)
  end

  after do
    ENV["BUCKET_NAME"] = nil
  end

  context "when exporting documents to s3" do
    it "executes the export assessment documents use case" do
      task.invoke
      expect(use_case).to have_received :execute
    end

    it "raises an error if no bucket name is provided" do
      ENV["BUCKET_NAME"] = nil

      expect { task.invoke }.to raise_error Boundary::ArgumentMissing
    end
  end

  context "when there is a error saving to S3" do
    before do
      allow(use_case).to receive(:execute).and_raise Aws::S3::Errors::ServiceError.new(Seahorse::Client::RequestContext, "something has gone wrong")
    end

    it "raises an error" do
      expect { task.invoke }.to raise_error Aws::S3::Errors::ServiceError
    end
  end
end

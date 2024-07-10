describe "ExportDocumentsRake" do
  subject(:task) { get_task("export_documents") }

  let(:storage_gateway) do
    Gateway::StorageGateway.new(bucket_name: ENV["BUCKET_NAME"], stub_responses: true)
  end

  let(:use_case) { instance_double(UseCase::ExportAssessmentDocuments) }

  before do
    ENV["BUCKET_NAME"] = "test"
    ENV["DATE_FROM"] = "2020-02-01"
    ENV["DATE_TO"] = "2020-03-01"
    allow(Container).to receive(:storage_gateway).and_return storage_gateway
    allow(UseCase::ExportAssessmentDocuments).to receive(:new).and_return use_case
    allow(use_case).to receive(:execute)
  end

  after do
    ENV["BUCKET_NAME"] = nil
    ENV["DATE_FROM"] = nil
    ENV["DATE_TO"] = nil
  end

  context "when exporting documents to s3" do
    it "executes the export assessment documents use case" do
      task.invoke
      expect(use_case).to have_received :execute
    end

    it "raises an error if no bucket name is provided" do
      ENV["BUCKET_NAME"] = nil

      expect { task.invoke }.to raise_error(Boundary::ArgumentMissing, "A required argument is missing: bucket_name")
    end

    it "raises an error if when the date_from is not provided" do
      ENV["DATE_FROM"] = nil

      expect { task.invoke }.to raise_error(Boundary::ArgumentMissing, "A required argument is missing: date_from")
    end

    it "raises an error if when the date_to is not provided" do
      ENV["DATE_TO"] = nil

      expect { task.invoke }.to raise_error(Boundary::ArgumentMissing, "A required argument is missing: date_to")
    end

    it "raises error if the date_from is after date_to" do
      ENV["DATE_FROM"] = "2020-03-01"
      ENV["DATE_TO"] = "2020-02-01"

      expect { task.invoke }.to raise_error(Boundary::InvalidDates, "date_from cannot be greater than date_to")
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

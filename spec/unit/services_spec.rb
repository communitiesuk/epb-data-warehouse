describe Services do
  let(:service) { "i am a service!" }

  context "when calling a use case service name defined in container" do
    before do
      allow(Container).to receive(:import_certificate_data_use_case).and_return(service)
    end

    it "finds and returns the service" do
      expect(described_class.use_case(:import_certificate_data)).to eq service
    end
  end

  context "when calling a gateway service name defined in container" do
    before do
      allow(Container).to receive(:register_api_gateway).and_return(service)
    end

    it "finds and returns the service" do
      expect(described_class.gateway(:register_api)).to eq service
    end
  end

  context "when calling a use case service name not defined in container" do
    it "raises a ServiceNotFound error" do
      expect { described_class.use_case(:i_do_not_exist) }.to raise_error Services::ServiceNotFound
    end
  end
end

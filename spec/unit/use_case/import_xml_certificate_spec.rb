describe UseCase::ImportXmlCertificate do
  context "call the use case import an xml document in the database" do
    let(:gateway) do
      Gateway::AssessmentAttributesGateway.new
    end

    let!(:assessment_id) {
      "0000-0000-0000-0000-0000"
    }

    let!(:use_case) do
      UseCase::ImportXmlCertificate.new(gateway)
    end

    let!(:sample) do
      Samples.xml("RdSAP-Schema-20.0.0")
    end

    let!(:transformed_certificate) do
      use_case.execute(sample, "RdSAP-Schema-20.0.0")
    end

    let(:saved_data) do
      ActiveRecord::Base.connection.exec_query("SELECT * FROM assessment_attribute_values WHERE assessment_id = '#{assessment_id}'")
    end

    it "transforms the xml using the view model to_report method " do
      expect(transformed_certificate).to be_a(Hash)
      expect(transformed_certificate[:assessment_id]).to eq("4af9d2c31cf53e72ef6f59d3f59a1bfc500ebc2b1027bc5ca47361435d988e1a")
    end

    it 'the attributes have been saved in the correct format' do
      use_case.execute(sample, "RdSAP-Schema-20.0.0")
      expect(saved_data.rows.length).not_to eq(0)
    end
  end
end

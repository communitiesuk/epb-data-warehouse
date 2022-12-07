shared_context "when saving json" do
  def save_assessment(assessment_id, assessment_data)
    import_use_case = UseCase::ImportCertificateData.new(assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, documents_gateway: Gateway::DocumentsGateway.new)
    import_use_case.execute(assessment_id:, certificate_data: assessment_data)
  end

  def get_fixture(fixture_file)
    path = File.join Dir.pwd, "spec/fixtures/document_store/#{fixture_file}"
    JSON.parse(File.read(path))
  end
end

describe Gateway::ReportingGateway do
  let(:gateway) { described_class.new }

  include_context "when saving json"

  describe "#heat_pump_count_for_sap" do
    after do
      Timecop.return
    end

    let(:heat_pump_data) do
      get_fixture("sap-18.0.0.json")
    end

    context "when fetching at no particular time" do
      let(:expected_data) do
        [{ month_year: "01-2022", num_epcs: 3 }]
      end

      before do
        Timecop.freeze(2022, 11, 30, 0, 0, 0)
        save_assessment("0000-0000-0000-0000-0000", get_fixture("sap-18.0.0.json"))
        heat_pump_data["main_heating"][0]["description"] = "Ground source heat pump, underfloor, electric"
        save_assessment("0000-0000-0000-0000-0001", heat_pump_data)
        heat_pump_data["main_heating"][0]["description"] = "Air source heat pump, warm air, electric"
        save_assessment("0000-0000-0000-0000-0002", heat_pump_data)
        heat_pump_data["main_heating"][0]["description"] = "Air source heat pump, warm air, electric"
        save_assessment("0000-0000-0000-0000-0003", heat_pump_data)
        heat_pump_data["registration_date"] = "2020-12-07"
        heat_pump_data["main_heating"][0]["description"] = "Ground source heat pump, underfloor, electric"
        save_assessment("0000-0000-0000-0000-0004", heat_pump_data)
      end

      it "returns a count of the 3 SAP saved with heat pump main heating in January 2022 " do
        result = gateway.heat_pump_count_for_sap.map { |hash| hash.transform_keys(&:to_sym) }
        expect(result).to eq expected_data
      end

      it "has another row for data lodged in October 2022" do
        heat_pump_data["registration_date"] = "2022-10-30"
        heat_pump_data["main_heating"][0]["description"] = "Ground source heat pump, underfloor, electric"
        save_assessment("0000-0000-0000-0000-0005", heat_pump_data)
        expect(gateway.heat_pump_count_for_sap.length).to eq(2)
        expect(gateway.heat_pump_count_for_sap[1]["month_year"]).to eq("10-2022")
        expect(gateway.heat_pump_count_for_sap[1]["num_epcs"]).to eq(1)
      end

      it "will count a row that has json stores as the main_heating description" do
        heat_pump_data["registration_date"] = "2022-11-03"
        heat_pump_data["main_heating"][0]["description"] = { "value": "Air source heat pump, Underfloor heating and radiators, pipes in screed above insulation, electric", "language": "1" }
        save_assessment("0000-0000-0000-0000-0005", heat_pump_data)
        expect(gateway.heat_pump_count_for_sap.length).to eq(1)
      end
    end

    context "when fetching in March of a year after a leap year" do
      before do
        Timecop.freeze(2025, 3, 15, 0, 0, 0)
        heat_pump_data["registration_date"] = "2024-02-29"
        heat_pump_data["main_heating"][0]["description"] = "Ground source heat pump, underfloor, electric"
        save_assessment("0000-0000-0000-0000-0000", heat_pump_data)
        heat_pump_data["registration_date"] = "2024-03-01"
        save_assessment("0000-0000-0000-0000-0001", heat_pump_data)
      end

      it "returns a count of 1 SAP saved with heat pump main heating between previous March and February of current year" do
        expect(gateway.heat_pump_count_for_sap.length).to eq 1
      end
    end
  end
end

require_relative "../../shared_context/shared_import_enums"

describe "When extracting the construction age band from domestic data" do
  include_context "when saving enum data to lookup tables"

  before(:all) do
    import_look_ups(schema_versions: %w[RdSAP-Schema-21.0.1])
  end

  let(:result) do
    sql = "SELECT fn_construction_age_band('#{json}', 'RdSAP', 'RdSAP-Schema-21.0.1') as construction_age_band"
    result = ActiveRecord::Base.connection.exec_query(sql)
    result.first["construction_age_band"]
  end

  context "when construction_age_band is present" do
    let(:json) do
      {
        "sap_building_parts": [
          {
            "construction_age_band": "M",
          },
        ],
      }.to_json
    end

    it "returns the construction value from the band" do
      expect(result).to eq("England and Wales: 2022 onwards")
    end
  end

  context "when construction_age_band is present in the 2nd item" do
    let(:json) do
      {
        "sap_building_parts": [
          {},
          {
            "construction_age_band": "M",
          },
        ],
      }.to_json
    end

    it "returns the construction value from the band" do
      expect(result).to eq("England and Wales: 2022 onwards")
    end
  end

  context "when construction_age_band is not present" do
    context "when construction year is present in the SAP" do
      let(:json) do
        {
          "sap_building_parts": [
            {
              "construction_year": "2021",
            },
          ],
        }.to_json
      end

      it "returns the construction year from the json" do
        expect(result).to eq("2021")
      end
    end

    context "when construction year is present in the 2nd item in SAP" do
      let(:json) do
        {
          "sap_building_parts": [
            {},
            {
              "construction_year": "2021",
            },
          ],
        }.to_json
      end

      it "returns the construction year from the json" do
        expect(result).to eq("2021")
      end
    end

    context "when construction year is not present" do
      let(:json) do
        {
          "sap_building_parts": [
            {},
          ],
        }.to_json
      end

      it "returns an empty string" do
        expect(result).to be_nil
      end
    end
  end
end

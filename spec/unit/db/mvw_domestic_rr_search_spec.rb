require_relative "../../shared_context/shared_lodgement"
require_relative "../../shared_context/shared_ons_data"
require_relative "../../shared_context/shared_data_export"
require_relative "../../shared_context/shared_recommendations"

describe "Domestic Recommendations Report" do
  let(:date_start) { "2021-12-01" }
  let(:date_end) { "2023-12-09" }
  let(:search_arguments) do
    { date_start:, date_end: }
  end

  include_context "when fetching recommendations report"
  include_context "when lodging XML"
  include_context "when saving ons data"
  include_context "when exporting data"

  describe "#fetch_rr" do
    before(:all) do
      import_postcode_directory_name
      import_postcode_directory_data
      config_path = "spec/config/attribute_improvements_map.json"
      config_gateway = Gateway::XsdConfigGateway.new(config_path)
      import_use_case = UseCase::ImportEnums.new(assessment_lookups_gateway: Gateway::AssessmentLookupsGateway.new, xsd_presenter: XmlPresenter::Xsd.new, assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, xsd_config_gateway: config_gateway)
      import_use_case.execute
      add_countries
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0017", schema_type: "SAP-Schema-12.0", type_of_assessment: "SAP", type: "sap", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0016", schema_type: "SAP-Schema-12.0", type_of_assessment: "RdSAP", type: "sap", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0015", schema_type: "SAP-Schema-14.0", type_of_assessment: "SAP", type: "sap", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0014", schema_type: "SAP-Schema-14.1", type_of_assessment: "SAP", type: "sap", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0013", schema_type: "SAP-Schema-14.2", type_of_assessment: "SAP", type: "sap", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0012", schema_type: "SAP-Schema-15.0", type_of_assessment: "SAP", type: "sap", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0009", schema_type: "SAP-Schema-16.1", type_of_assessment: "SAP", type: "sap", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0006", schema_type: "RdSAP-Schema-20.0.0", type_of_assessment: "RdSAP", type: "epc", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0010", schema_type: "RdSAP-Schema-21.0.1", type_of_assessment: "RdSAP", type: "epc", different_fields: {
        "postcode": "SW10 0AA", "country_id": 1
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0011", schema_type: "RdSAP-Schema-NI-21.0.1", type_of_assessment: "RdSAP", type: "epc", different_fields: {
        "postcode": "BT1 0AA", "country_id": 3
      })

      Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_domestic_search")
      Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_domestic_rr_search")
    end

    let(:data) do
      retry_mview(name: "mvw_domestic_rr_search") do
        fetch_rr
      end
    end

    let(:expected_rdsap_data) do
      [{ "certificate_number" => "0000-0000-0000-0000-0006",
         "improvement_item" => 1,
         "improvement_id" => "5",
         "indicative_cost" => "£100 - £350",
         "improvement_summary_text" => "Increase loft insulation to 270 mm",
         "improvement_descr_text" => "Loft insulation laid in the loft space or between roof rafters to a depth of at least 270 mm will significantly reduce heat loss through the roof; this will improve levels of comfort, reduce energy use and lower fuel bills. Insulation should not be placed below any cold water storage tank; any such tank should also be insulated on its sides and top, and there should be boarding on battens over the insulation to provide safe access between the loft hatch and the cold water tank. The insulation can be installed by professional contractors but also by a capable DIY enthusiast. Loose granules may be used instead of insulation quilt; this form of loft insulation can be blown into place and can be useful where access is difficult. The loft space must have adequate ventilation to prevent dampness; seek advice about this if unsure (particularly if installing insulation between rafters because a vapour control layer and ventilation above the insulation are required). Further information about loft insulation and details of local contractors can be obtained from the National Insulation Association (www.nationalinsulationassociation.org.uk)." },
       { "certificate_number" => "0000-0000-0000-0000-0006",
         "improvement_item" => 2,
         "improvement_id" => "1",
         "indicative_cost" => "2000",
         "improvement_summary_text" => "Insulate hot water cylinder with 80 mm jacket",
         "improvement_descr_text" => "Installing an 80 mm thick cylinder jacket around the hot water cylinder will help to maintain the water at the required temperature; this will reduce the amount of energy used and lower fuel bills. A cylinder jacket is a layer of insulation that is fitted around the hot water cylinder. The jacket should be fitted over any thermostat clamped to the cylinder. Hot water pipes from the hot water cylinder should also be insulated, using pre-formed pipe insulation of up to 50 mm thickness (or to suit the space available) for as far as they can be accessed to reduce losses in summer. All these materials can be purchased from DIY stores and installed by a competent DIY enthusiast." },
       { "certificate_number" => "0000-0000-0000-0000-0006",
         "improvement_item" => 3,
         "improvement_id" => nil,
         "indicative_cost" => "1000",
         "improvement_summary_text" => "An improvement summary",
         "improvement_descr_text" => "An improvement desc" }]
    end

    let(:expected_rdsap_21_0_1_data) do
      [{ "certificate_number" => "0000-0000-0000-0000-0010",
         "improvement_item" => 1,
         "improvement_id" => "66",
         "indicative_cost" => "£220 - £250",
         "improvement_summary_text" => "Internal insulation with cavity wall insulation",
         "improvement_descr_text" => ".." },
       { "certificate_number" => "0000-0000-0000-0000-0010",
         "improvement_item" => 2,
         "improvement_id" => "19",
         "indicative_cost" => "£4,000 - £7,000",
         "improvement_summary_text" => "Solar water heating",
         "improvement_descr_text" => "A solar water heating panel, usually fixed to the roof, uses the sun to pre-heat the hot water supply. This will significantly reduce the demand on the heating system to provide hot water and hence save fuel and money. The Solar Trade Association has up-to-date information on local installers." },
       { "certificate_number" => "0000-0000-0000-0000-0010",
         "improvement_item" => 3,
         "improvement_id" => "34",
         "indicative_cost" => "£8,000 - £10,000",
         "improvement_summary_text" => "Solar photovoltaic panels, 2.5 kWp",
         "improvement_descr_text" => "A solar PV system is one which converts light directly into electricity via panels placed on the roof with no waste and no emissions. This electricity is used throughout the home in the same way as the electricity purchased from an energy supplier. The British Photovoltaic Association has up-to-date information on local installers who are qualified electricians. It is best to obtain advice from a qualified electrician. Ask the electrician to explain the options." }]
    end

    let(:expected_rdsap_120_data) do
      [{ "certificate_number" => "0000-0000-0000-0000-0016",
         "improvement_item" => 1,
         "improvement_id" => nil,
         "indicative_cost" => nil,
         "improvement_summary_text" => "Low energy lighting for all fixed outlets",
         "improvement_descr_text" => "Replacement of traditional light bulbs with energy saving recommended ones will reduce lighting costs over the lifetime of the bulb, and they last up to 12 times longer than ordinary light bulbs. Also consider selecting low energy light fittings when redecorating; contact the Lighting Association for your nearest stockist of Domestic Energy Efficient Lighting Scheme fittings." },
       { "certificate_number" => "0000-0000-0000-0000-0016",
         "improvement_item" => 2,
         "improvement_id" => nil,
         "indicative_cost" => nil,
         "improvement_summary_text" => nil,
         "improvement_descr_text" => "Improvement desc" }]
    end

    let(:expected_sap_16_1_rr_data) do
      [{ "certificate_number" => "0000-0000-0000-0000-0009",
         "improvement_item" => 1,
         "improvement_id" => "35",
         "indicative_cost" => "£15",
         "improvement_summary_text" => "Low energy lighting for all fixed outlets",
         "improvement_descr_text" => "Replacement of traditional light bulbs with energy saving recommended ones will reduce lighting costs over the lifetime of the bulb, and they last up to 12 times longer than ordinary light bulbs. Also consider selecting low energy light fittings when redecorating; contact the Lighting Association for your nearest stockist of Domestic Energy Efficient Lighting Scheme fittings." },
       { "certificate_number" => "0000-0000-0000-0000-0009",
         "improvement_item" => 2,
         "improvement_id" => "19",
         "indicative_cost" => "£4,000 - £6,000",
         "improvement_summary_text" => "Solar water heating",
         "improvement_descr_text" => "A solar water heating panel, usually fixed to the roof, uses the sun to pre-heat the hot water supply. This will significantly reduce the demand on the heating system to provide hot water and hence save fuel and money. The Solar Trade Association has up-to-date information on local installers." }]
    end
    let(:expected_sap_12_0_data) do
      [{ "certificate_number" => "0000-0000-0000-0000-0017",
         "improvement_descr_text" => "Replacement of traditional light bulbs with energy saving recommended ones will reduce lighting costs over the lifetime of the bulb, and they last up to 12 times longer than ordinary light bulbs. Also consider selecting low energy light fittings when redecorating; contact the Lighting Association for your nearest stockist of Domestic Energy Efficient Lighting Scheme fittings.",
         "improvement_id" => nil,
         "improvement_item" => 1,
         "improvement_summary_text" => "Low energy lighting for all fixed outlets",
         "indicative_cost" => nil },
       { "certificate_number" => "0000-0000-0000-0000-0017",
         "improvement_descr_text" => "Improvement desc",
         "improvement_id" => nil,
         "improvement_item" => 2,
         "improvement_summary_text" => nil,
         "indicative_cost" => nil }]
    end
    let(:expected_sap_14_0_data) do
      [{ "certificate_number" => "0000-0000-0000-0000-0015",
         "improvement_descr_text" => "Loft insulation laid in the loft space or between roof rafters to a depth of at least 270 mm will significantly reduce heat loss through the roof; this will improve levels of comfort, reduce energy use and lower fuel bills. Insulation should not be placed below any cold water storage tank, any such tank should also be insulated on its sides and top, and there should be boarding on battens over the insulation to provide safe access between the loft hatch and the cold water tank. The insulation can be installed by professional contractors but also by a capable DIY enthusiast. Loose granules may be used instead of insulation quilt; this form of loft insulation can be blown into place and can be useful where access is difficult. The loft space must have adequate ventilation to prevent dampness; seek advice about this if unsure. Further information about loft insulation and details of local contractors can be obtained from the National Insulation Association (www.nationalinsulationassociation.org.uk).",
         "improvement_id" => "5",
         "improvement_item" => 1,
         "improvement_summary_text" => "Increase loft insulation to 270 mm",
         "indicative_cost" => nil },
       { "certificate_number" => "0000-0000-0000-0000-0015",
         "improvement_descr_text" => "Improvement desc",
         "improvement_id" => nil,
         "improvement_item" => 2,
         "improvement_summary_text" => nil,
         "indicative_cost" => nil }]
    end

    let(:expected_sap_14_1_data) do
      [{ "certificate_number" => "0000-0000-0000-0000-0014",
         "improvement_descr_text" => "Loft insulation laid in the loft space or between roof rafters to a depth of at least 270 mm will significantly reduce heat loss through the roof; this will improve levels of comfort, reduce energy use and lower fuel bills. Insulation should not be placed below any cold water storage tank, any such tank should also be insulated on its sides and top, and there should be boarding on battens over the insulation to provide safe access between the loft hatch and the cold water tank. The insulation can be installed by professional contractors but also by a capable DIY enthusiast. Loose granules may be used instead of insulation quilt; this form of loft insulation can be blown into place and can be useful where access is difficult. The loft space must have adequate ventilation to prevent dampness; seek advice about this if unsure. Further information about loft insulation and details of local contractors can be obtained from the National Insulation Association (www.nationalinsulationassociation.org.uk).",
         "improvement_id" => "5",
         "improvement_item" => 1,
         "improvement_summary_text" => "Increase loft insulation to 270 mm",
         "indicative_cost" => nil },
       { "certificate_number" => "0000-0000-0000-0000-0014",
         "improvement_descr_text" => "Improvement desc",
         "improvement_id" => nil,
         "improvement_item" => 2,
         "improvement_summary_text" => nil,
         "indicative_cost" => nil }]
    end

    let(:expected_sap_14_2_data) do
      [{ "certificate_number" => "0000-0000-0000-0000-0013",
         "improvement_descr_text" => "Loft insulation laid in the loft space or between roof rafters to a depth of at least 270 mm will significantly reduce heat loss through the roof; this will improve levels of comfort, reduce energy use and lower fuel bills. Insulation should not be placed below any cold water storage tank, any such tank should also be insulated on its sides and top, and there should be boarding on battens over the insulation to provide safe access between the loft hatch and the cold water tank. The insulation can be installed by professional contractors but also by a capable DIY enthusiast. Loose granules may be used instead of insulation quilt; this form of loft insulation can be blown into place and can be useful where access is difficult. The loft space must have adequate ventilation to prevent dampness; seek advice about this if unsure. Further information about loft insulation and details of local contractors can be obtained from the National Insulation Association (www.nationalinsulationassociation.org.uk).",
         "improvement_id" => "5",
         "improvement_item" => 1,
         "improvement_summary_text" => "Increase loft insulation to 270 mm",
         "indicative_cost" => nil },
       { "certificate_number" => "0000-0000-0000-0000-0013",
         "improvement_descr_text" => "Improvement desc",
         "improvement_id" => nil,
         "improvement_item" => 2,
         "improvement_summary_text" => nil,
         "indicative_cost" => nil }]
    end

    let(:expected_sap_15_0_data) do
      [{ "certificate_number" => "0000-0000-0000-0000-0012",
         "improvement_descr_text" =>
              "Replacement of traditional light bulbs with energy saving recommended ones will reduce lighting costs over the lifetime of the bulb, and they last up to 12 times longer than ordinary light bulbs. Also consider selecting low energy light fittings when redecorating; contact the Lighting Association for your nearest stockist of Domestic Energy Efficient Lighting Scheme fittings.",
         "improvement_id" => "35",
         "improvement_item" => 1,
         "improvement_summary_text" => "Low energy lighting for all fixed outlets",
         "indicative_cost" => "??18" }]
    end

    context "when fetching RdSAP assessments" do
      it "returns the recommendations for the RdSAP 12.0 assessment" do
        items = data.select { |i| i["certificate_number"] == "0000-0000-0000-0000-0016" }.sort_by { |i| i["improvement_item"] }
        expect(items).to eq expected_rdsap_120_data
      end

      it "returns the recommendations for the RdSAP 20.0.0 assessment" do
        items = data.select { |i| i["certificate_number"] == "0000-0000-0000-0000-0006" }.sort_by { |i| i["improvement_item"] }
        expect(items).to eq expected_rdsap_data
      end

      it "returns the recommendations for the RdSAP 21.0.1 assessment" do
        items = data.select { |i| i["certificate_number"] == "0000-0000-0000-0000-0010" }.sort_by { |i| i["improvement_item"] }
        expect(items).to eq expected_rdsap_21_0_1_data
      end
    end

    context "when fetching SAP assessments" do
      it "returns the recommendations for SAP 12.0" do
        items = data.select { |i| i["certificate_number"] == "0000-0000-0000-0000-0017" }.sort_by { |i| i["improvement_item"] }
        expect(items).to eq expected_sap_12_0_data
      end

      it "returns the recommendations for SAP 14.0" do
        items = data.select { |i| i["certificate_number"] == "0000-0000-0000-0000-0015" }.sort_by { |i| i["improvement_item"] }
        expect(items).to eq expected_sap_14_0_data
      end

      it "returns the recommendations for SAP 14.1" do
        items = data.select { |i| i["certificate_number"] == "0000-0000-0000-0000-0014" }.sort_by { |i| i["improvement_item"] }
        expect(items).to eq expected_sap_14_1_data
      end

      it "returns the recommendations for SAP 14.2" do
        items = data.select { |i| i["certificate_number"] == "0000-0000-0000-0000-0013" }.sort_by { |i| i["improvement_item"] }
        expect(items).to eq expected_sap_14_2_data
      end

      it "returns the recommendations for SAP 15.0" do
        items = data.select { |i| i["certificate_number"] == "0000-0000-0000-0000-0012" }.sort_by { |i| i["improvement_item"] }
        expect(items).to eq expected_sap_15_0_data
      end

      it "returns the recommendations for SAP 16.1" do
        items = data.select { |i| i["certificate_number"] == "0000-0000-0000-0000-0009" }.sort_by { |i| i["improvement_item"] }
        expect(items[0]).to eq expected_sap_16_1_rr_data[0]
        expect(items[1]).to eq expected_sap_16_1_rr_data[1]
        expect(items.length).to eq 4
      end
    end

    it "the grouped results the expected certificate_numbers" do
      group = data.group_by { |i| i["certificate_number"] }
      expect(group.length).to eq 9
    end

    it "does not include the rows for NI assessments" do
      expect(data.map { |i| i["certificate_number"] }).not_to include("0000-0000-0000-0000-0011")
    end
  end
end

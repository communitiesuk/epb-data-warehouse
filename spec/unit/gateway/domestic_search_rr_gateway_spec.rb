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
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0009", schema_type: "SAP-Schema-16.1", type_of_assessment: "SAP", type: "sap", different_fields: {
        "postcode": "SW10 0AA",
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0006", schema_type: "RdSAP-Schema-20.0.0", type_of_assessment: "RdSAP", type: "epc", different_fields: {
        "postcode": "SW10 0AA",
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0010", schema_type: "RdSAP-Schema-21.0.1", type_of_assessment: "RdSAP", type: "epc", different_fields: {
        "postcode": "SW10 0AA",
      })
      Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_domestic_search")
      Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_domestic_rr_search")
    end

    let(:data) do
      retry_mview(name: "mvw_domestic_rr_search") do
        fetch_rr
      end
    end

    let(:expected_sap_rr_data) do
      [{ "rrn" => "0000-0000-0000-0000-0009",
         "improvement_item" => 1,
         "improvement_id" => "35",
         "indicative_cost" => "£15",
         "improvement_summary_text" => "Low energy lighting for all fixed outlets",
         "improvement_descr_text" => "Replacement of traditional light bulbs with energy saving recommended ones will reduce lighting costs over the lifetime of the bulb, and they last up to 12 times longer than ordinary light bulbs. Also consider selecting low energy light fittings when redecorating; contact the Lighting Association for your nearest stockist of Domestic Energy Efficient Lighting Scheme fittings." },
       { "rrn" => "0000-0000-0000-0000-0009",
         "improvement_item" => 2,
         "improvement_id" => "19",
         "indicative_cost" => "£4,000 - £6,000",
         "improvement_summary_text" => "Solar water heating",
         "improvement_descr_text" => "A solar water heating panel, usually fixed to the roof, uses the sun to pre-heat the hot water supply. This will significantly reduce the demand on the heating system to provide hot water and hence save fuel and money. The Solar Trade Association has up-to-date information on local installers." }]
    end

    let(:expected_rdsap_data) do
      [{ "rrn" => "0000-0000-0000-0000-0006",
         "improvement_item" => 1,
         "improvement_id" => "5",
         "indicative_cost" => "£100 - £350",
         "improvement_summary_text" => "Increase loft insulation to 270 mm",
         "improvement_descr_text" => "Loft insulation laid in the loft space or between roof rafters to a depth of at least 270 mm will significantly reduce heat loss through the roof; this will improve levels of comfort, reduce energy use and lower fuel bills. Insulation should not be placed below any cold water storage tank; any such tank should also be insulated on its sides and top, and there should be boarding on battens over the insulation to provide safe access between the loft hatch and the cold water tank. The insulation can be installed by professional contractors but also by a capable DIY enthusiast. Loose granules may be used instead of insulation quilt; this form of loft insulation can be blown into place and can be useful where access is difficult. The loft space must have adequate ventilation to prevent dampness; seek advice about this if unsure (particularly if installing insulation between rafters because a vapour control layer and ventilation above the insulation are required). Further information about loft insulation and details of local contractors can be obtained from the National Insulation Association (www.nationalinsulationassociation.org.uk)." },
       { "rrn" => "0000-0000-0000-0000-0006",
         "improvement_item" => 2,
         "improvement_id" => "1",
         "indicative_cost" => "2000",
         "improvement_summary_text" => "Insulate hot water cylinder with 80 mm jacket",
         "improvement_descr_text" => "Installing an 80 mm thick cylinder jacket around the hot water cylinder will help to maintain the water at the required temperature; this will reduce the amount of energy used and lower fuel bills. A cylinder jacket is a layer of insulation that is fitted around the hot water cylinder. The jacket should be fitted over any thermostat clamped to the cylinder. Hot water pipes from the hot water cylinder should also be insulated, using pre-formed pipe insulation of up to 50 mm thickness (or to suit the space available) for as far as they can be accessed to reduce losses in summer. All these materials can be purchased from DIY stores and installed by a competent DIY enthusiast." },
       { "rrn" => "0000-0000-0000-0000-0006",
         "improvement_item" => 3,
         "improvement_id" => nil,
         "indicative_cost" => "1000",
         "improvement_summary_text" => "An improvement summary",
         "improvement_descr_text" => "An improvement desc" }]
    end

    it "returns the recommendations for a the RdSAP assessment" do
      items = data.select { |i| i["rrn"] == "0000-0000-0000-0000-0006" }.sort_by { |i| i["improvement_item"] }
      expect(items).to eq expected_rdsap_data
    end

    it "returns the recommendations for a the RdSAP 21.0.1 assessment" do
      rdsap =
        [{ "rrn" => "0000-0000-0000-0000-0010",
           "improvement_item" => 1,
           "improvement_id" => "66",
           "indicative_cost" => "£220 - £250",
           "improvement_summary_text" => "Internal insulation with cavity wall insulation",
           "improvement_descr_text" => ".." },
         { "rrn" => "0000-0000-0000-0000-0010",
           "improvement_item" => 2,
           "improvement_id" => "19",
           "indicative_cost" => "£4,000 - £7,000",
           "improvement_summary_text" => "Solar water heating",
           "improvement_descr_text" => "A solar water heating panel, usually fixed to the roof, uses the sun to pre-heat the hot water supply. This will significantly reduce the demand on the heating system to provide hot water and hence save fuel and money. The Solar Trade Association has up-to-date information on local installers." },
         { "rrn" => "0000-0000-0000-0000-0010",
           "improvement_item" => 3,
           "improvement_id" => "34",
           "indicative_cost" => "£8,000 - £10,000",
           "improvement_summary_text" => "Solar photovoltaic panels, 2.5 kWp",
           "improvement_descr_text" => "A solar PV system is one which converts light directly into electricity via panels placed on the roof with no waste and no emissions. This electricity is used throughout the home in the same way as the electricity purchased from an energy supplier. The British Photovoltaic Association has up-to-date information on local installers who are qualified electricians. It is best to obtain advice from a qualified electrician. Ask the electrician to explain the options." }]

      items = data.select { |i| i["rrn"] == "0000-0000-0000-0000-0010" }.sort_by { |i| i["improvement_item"] }
      expect(items).to eq rdsap
    end

    it "returns the recommendations text for the SAP of 16.1" do
      items = data.select { |i| i["rrn"] == "0000-0000-0000-0000-0009" }.sort_by { |i| i["improvement_item"] }
      expect(items[0]).to eq expected_sap_rr_data[0]
      expect(items[1]).to eq expected_sap_rr_data[1]
      expect(items.length).to eq 4
    end

    it "the grouped results have 2 RRNs" do
      group = data.group_by { |i| i["rrn"] }
      expect(group.length).to eq 3
    end

    context "when the json is not is an hash with a single item rather than an array" do
      let(:single_improvement) do
        [{
          improvement: {
            sequence: 1,
            typical_saving: {
              value: 38,
              currency: "GBP",
            },
            indicative_cost: "£4,000 - £6,000",
            improvement_type: "W2",
            improvement_details: {
              improvement_number: 58,
            },
            improvement_category: 5,
            energy_performance_rating: 74,
            environmental_impact_rating: 78,
          },
        }]
      end

      before do
        sql = <<-SQL
           UPDATE assessment_attribute_values aav
            SET json  = $1
            FROM assessment_attributes aa
            WHERE  aav.attribute_id = aa.attribute_id
            AND aa.attribute_name = $2 AND aav.assessment_id = $3
        SQL

        bindings = [
          ActiveRecord::Relation::QueryAttribute.new(
            "json",
            single_improvement,
            ActiveRecord::Type::Json.new,
          ),
          ActiveRecord::Relation::QueryAttribute.new(
            "attribute_name",
            "suggested_improvements",
            ActiveRecord::Type::String.new,
          ),
          ActiveRecord::Relation::QueryAttribute.new(
            "assessment_id",
            "0000-0000-0000-0000-0006",
            ActiveRecord::Type::String.new,
          ),
        ]
        ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)
        Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_domestic_rr_search")
      end

      it "returns the single recommendation" do
        items = data.select { |i| i["rrn"] == "0000-0000-0000-0000-0006" }
        expect(items.length).to eq 1
      end
    end
  end
end

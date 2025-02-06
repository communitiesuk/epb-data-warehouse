require_relative "../shared_context/shared_import_enumns"

describe "ImportEnumsXsd Rake" do
  subject(:task) { get_task("import_enums_xsd") }

  context "when the import task runs with the test config" do
    before do
      allow($stdout).to receive(:puts)
      allow($stdout).to receive(:write)
    end

    it "runs the task without raising any errors" do
      expect { task.invoke("spec/config/task_attribute_enum_map.json") }.not_to raise_error
    end

    context "when checking the saved data" do
      include_context "when saving enum data to lookup tables"

      before(:all) do
        get_task("import_enums_xsd").invoke("spec/config/attribute_improvements_map.json")
      end

      context "when checking improvement_summary enums for RdSAP" do
        let(:attribute_name) { "improvement_summary" }

        let(:data) do
          fetch_saved_data(attribute_name:)
        end

        let(:counts) do
          fetch_counts(attribute_name:)
        end

        it "saves Insulate hot water cylinder for Improvement-Number 1" do
          expect(data.find { |i| i["lookup_key"] == "1" }["lookup_value"]).to eq "Insulate hot water cylinder with 80 mm jacket"
        end

        it "saves party wall insulation Improvement-Number 63 in RD-SAP.21.0" do
          expect(data.find { |i| i["lookup_key"] == "63" && i["schema_version"] == "RdSAP-Schema-21.0.0" }["lookup_value"]).to eq "Party wall insulation"
        end

        it "saves all improvement_summary values for the latest version of RdSAP" do
          expect(counts.find { |i| i["schema_version"] == "RdSAP-Schema-21.0.0" }["cnt"]).to eq 55
        end

        it "saves all improvement_summary values for the older version of RdSAP" do
          expect(counts.find { |i| i["schema_version"] == "RdSAP-Schema-17.0" }["cnt"]).to eq 52
        end
      end

      context "when checking improvement_summary enums for SAP" do
        let(:attribute_name) { "improvement_summary" }

        let(:data) do
          fetch_saved_data(attribute_name:)
        end

        let(:counts) do
          fetch_counts(attribute_name:)
        end

        it "saves party wall insulation Improvement-Number 55 in SAP.19.0" do
          expect(data.find { |i| i["lookup_key"] == "55" && i["schema_version"] == "SAP-Schema-19.0.0" }["lookup_value"]).to eq "External insulation with cavity wall insulation"
        end

        it "saves all the improvement_summary values for the latest version of SAP" do
          expect(counts.find { |i| i["schema_version"] == "SAP-Schema-19.0.0" }["cnt"]).to eq 50
        end

        it "saves all improvement_summary values for the older version of SAP" do
          olds_schemes = %w[SAP-Schema-16.1 SAP-Schema-17.0]
          expect(counts.map { |row| row["schema_version"] }).to include(*olds_schemes)
        end
      end

      context "when checking improvement_description enums for RdSAP" do
        let(:attribute_name) { "improvement_description" }

        let(:data) do
          fetch_saved_data(attribute_name:)
        end

        let(:counts) do
          fetch_counts(attribute_name:)
        end

        it "saves correct text for Improvement-Number 1" do
          text = "Installing an 80 mm thick cylinder jacket around the hot water cylinder will help to maintain the water at the required temperature; this will reduce the amount of energy used and lower fuel bills. A cylinder jacket is a layer of insulation that is fitted around the hot water cylinder. The jacket should be fitted over any thermostat clamped to the cylinder. Hot water pipes from the hot water cylinder should also be insulated, using pre-formed pipe insulation of up to 50 mm thickness (or to suit the space available) for as far as they can be accessed to reduce losses in summer. All these materials can be purchased from DIY stores and installed by a competent DIY enthusiast."
          expect(data.find { |i| i["lookup_key"] == "1" }["lookup_value"]).to eq text
        end

        it "saves the correct text Improvement-Number 63 in SAP.21.0" do
          expect(data.find { |i| i["lookup_key"] == "63" && i["schema_version"] == "RdSAP-Schema-21.0.0" }["lookup_value"]).to match(/Party wall insulation, to fill the gap in the wall separating two or more dwellings walls with/)
        end

        it "saves all improvement_description values for the latest version of RdSAP" do
          expect(counts.find { |i| i["schema_version"] == "RdSAP-Schema-21.0.0" }["cnt"]).to eq 55
        end

        it "saves all improvement_description values for the older version of RdSAP" do
          expect(counts.find { |i| i["schema_version"] == "RdSAP-Schema-17.0" }["cnt"]).to eq 52
        end
      end

      context "when checking improvement_description enums for SAP-Schema" do
        let(:attribute_name) { "improvement_description" }

        let(:data) do
          fetch_saved_data(attribute_name:)
        end

        let(:counts) do
          fetch_counts(attribute_name:)
        end

        it "saves the correct text for Improvement-Number in SAP.19.0" do
          text = "A flue gas heat recovery system extracts heat from the boiler flue gases and transfers it to the incoming cold water so that the boiler needs to supply less heat. It is suitable for use only with a modern condensing gas boiler and should be fitted when a replacement boiler is installed."
          expect(data.find { |i| i["lookup_key"] == "50" && i["schema_version"] == "SAP-Schema-19.0.0" }["lookup_value"]).to eq text
        end

        it "when there is no description for a number" do
          expect(data.find { |i| i["lookup_key"] == "51" && i["schema_version"] == "SAP-Schema-19.0.0" }["lookup_value"]).to eq ".."
        end

        it "saves all the improvement_description values for the latest version of SAP" do
          expect(counts.find { |i| i["schema_version"] == "SAP-Schema-19.0.0" }["cnt"]).to eq 50
        end

        it "saves all improvement_description values for the older version of SAP" do
          olds_schemes = %w[SAP-Schema-16.1 SAP-Schema-17.0]
          expect(counts.map { |row| row["schema_version"] }).to include(*olds_schemes)
        end
      end
    end
  end
end

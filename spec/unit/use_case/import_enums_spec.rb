describe UseCase::ImportEnums do
  include_context "when saving enum data to lookup tables"

  let(:use_case) do
    described_class.new(assessment_lookups_gateway: gateway, xsd_presenter: presenter, assessment_attribute_gateway: attribute_gateway, xsd_config_gateway:)
  end

  let(:gateway) do
    instance_double(Gateway::AssessmentLookupsGateway)
  end

  let(:attribute_gateway) do
    instance_double(Gateway::AssessmentAttributesGateway)
  end

  let(:xsd_config_gateway) do
    Gateway::XsdConfigGateway.new("spec/config/attribute_enum_map.json")
  end

  let(:presenter) do
    XmlPresenter::Xsd.new
  end

  context "when receiving enums that have variations between schema versions for an attribute" do
    before do
      allow(gateway).to receive(:add_lookup).with(anything).and_return(1)
      allow(attribute_gateway).to receive(:add_attribute).and_return("1")
      allow(gateway).to receive(:truncate_tables)

      allow(presenter).to receive(:get_enums_by_type).and_return(
        { "RdSap-18.0.0" => { "1" => "a", "2" => "b", "3" => "c", "nr" => "other" },
          "RdSap-17.0.0" => { "1" => "a1", "2" => "b1", "3" => "c1", "nr" => "other1" } },
      )
    end

    it "receive the array and loop over it the correct number of times" do
      use_case.execute
      expect(gateway).to have_received(:truncate_tables).exactly(1).times
      expect(presenter).to have_received(:get_enums_by_type).exactly(2).times
      expect(gateway).to have_received(:add_lookup).exactly(16).times
    end
  end

  context "when receiving enums that have no variations between schema versions for an attribute" do
    before do
      allow(xsd_config_gateway).to receive(:nodes_and_paths).and_return([{
        "attribute_name" => "construction_age_band",
        "type_of_assessment" => "RdSAP",
        "xsd_node_name" => "test",
        "xsd_path" => "/api/schemas/xml/RdSAP**/RdSAP/UDT/*-Domains.xsd",
      }])
      allow(gateway).to receive(:add_lookup).with(anything).and_return(1)
      allow(gateway).to receive(:truncate_tables)
      allow(attribute_gateway).to receive(:add_attribute).and_return("1")
      allow(presenter).to receive(:get_enums_by_type).and_return(
        { "RdSap-18.0.0" => { "1" => "a", "2" => "b", "3" => "c", "nr" => "other" },
          "RdSap-17.0.0" => { "1" => "a", "2" => "b", "3" => "c", "nr" => "other" } },
      )
    end

    it "receive the array and loop over it for every lookup in each schema" do
      use_case.execute
      expect(presenter).to have_received(:get_enums_by_type).exactly(1).times
      expect(gateway).to have_received(:add_lookup).exactly(8).times
    end
  end

  context "when calling the xml_presenter with a non existing node name" do
    let(:arguments) do
      [{
        "attribute_name" => "construction_age_band",
        "type_of_assessment" => "RdSAP",
        "xsd_node_name" => "blah",
        "xsd_path" => "/api/schemas/xml/RdSAP**/RdSAP/UDT/*-Domains.xsd",
      }]
    end

    let(:xsd_config) do
      instance_double(Gateway::XsdConfigGateway)
    end

    let(:use_case) do
      described_class.new(assessment_lookups_gateway: Gateway::AssessmentLookupsGateway.new,
                          xsd_presenter: presenter, assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, xsd_config_gateway: xsd_config)
    end

    before do
      allow(xsd_config).to receive(:nodes_and_paths).and_return(arguments)
    end

    it "the xml_presenter raises an error which is bubbled up to the use case and rethrown" do
      expect { use_case.execute }.to raise_error(Boundary::EnumImportError, /Unable to import attribute blah/)
    end
  end

  context "when calling the xml_presenter with a an incorrect path" do
    let(:arguments) do
      [{
        "attribute_name" => "tenure",
        "type_of_assessment" => "RdSAP",
        "xsd_node_name" => "TenureCode",
        "xsd_path" => "/api/schemas/xml/RdSAP**/RdSAP/UDT/*-test.xsd",
      }]
    end

    let(:xsd_config) do
      instance_double(Gateway::XsdConfigGateway)
    end

    let(:use_case) do
      described_class.new(assessment_lookups_gateway: Gateway::AssessmentLookupsGateway.new,
                          xsd_presenter: Presenter::Xsd.new, assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, xsd_config_gateway: xsd_config)
    end

    before do
      allow(xsd_config).to receive(:nodes_and_paths).and_return(arguments)
    end

    it "the xml_presenter raises an error which is bubbled up to the use case and rethrown" do
      expect { use_case.execute }.to raise_error(Boundary::EnumImportError, /Unable to import attribute TenureCode : No xsd files were found in /)
    end
  end

  context "when saving the construction age band enums" do
    let(:lookups_gateway)  do
      Gateway::AssessmentLookupsGateway.new
    end

    before(:all) do
      lookups_gateway = Gateway::AssessmentLookupsGateway.new
      xsd_config = Gateway::XsdConfigGateway.new("spec/config/construction_age_band.json")
      use_case = described_class.new(assessment_lookups_gateway: lookups_gateway, xsd_presenter: Presenter::Xsd.new, assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, xsd_config_gateway: xsd_config)
      use_case.execute
    end

    it "returns the expected enum value for a L in England and Northern Ireland" do
      enum_value = ActiveRecord::Base.connection.exec_query("SELECT lookup_value
        FROM assessment_attribute_lookups aal
        INNER JOIN assessment_lookups al on aal.lookup_id = al.id
        INNER JOIN assessment_attributes aa on aal.attribute_id = aa.attribute_id
        WHERE aa.attribute_name = 'construction_age_band' and lookup_key = 'A'").first["lookup_value"]
      expect(enum_value).to eq("England and Wales: before 1900")
    end

    it "only has L values for the expected schema versions" do
      expected_versions = %w[RdSAP-Schema-20.0.0
                             RdSAP-Schema-19.0
                             RdSAP-Schema-18.0
                             RdSAP-Schema-17.1
                             RdSAP-Schema-17.0
                             RdSAP-Schema-NI-20.0.0
                             RdSAP-Schema-NI-19.0
                             RdSAP-Schema-NI-18.0
                             RdSAP-Schema-NI-17.4
                             RdSAP-Schema-NI-17.3]

      data = ActiveRecord::Base.connection.exec_query("SELECT DISTINCT schema_version
        FROM assessment_attribute_lookups aal
        INNER JOIN assessment_lookups al on aal.lookup_id = al.id
        INNER JOIN assessment_attributes aa on aal.attribute_id = aa.attribute_id
        WHERE aa.attribute_name = 'construction_age_band' AND lookup_key = 'L' AND aal.type_of_assessment='RdSAP'")

      expect(data.rows.flatten - expected_versions).to eq([])
    end

    it "checks the schemas that use 0" do
      schemes_that_use_0 = %w[
        RdSAP-Schema-20.0.0
        RdSAP-Schema-19.0
        RdSAP-Schema-18.0
        RdSAP-Schema-17.1
        RdSAP-Schema-17.0
        RdSAP-Schema-NI-20.0.0
        RdSAP-Schema-NI-19.0
        RdSAP-Schema-NI-18.0
        RdSAP-Schema-NI-17.4
        RdSAP-Schema-NI-17.3
      ]

      data = ActiveRecord::Base.connection.exec_query("SELECT DISTINCT schema_version
        FROM assessment_attribute_lookups aal
        INNER JOIN assessment_lookups al on aal.lookup_id = al.id
        INNER JOIN assessment_attributes aa on aal.attribute_id = aa.attribute_id
        WHERE aa.attribute_name = 'construction_age_band' AND lookup_key = '0'")
      expect(schemes_that_use_0 - data.rows.flatten).to eq([])
    end
  end

  context "when saving data across a range of SAP schemas" do
    before do
      lookups_gateway = Gateway::AssessmentLookupsGateway.new
      xsd_config = Gateway::XsdConfigGateway.new("spec/config/construction_age_band_sap.json")
      use_case = described_class.new(assessment_lookups_gateway: lookups_gateway, xsd_presenter: Presenter::Xsd.new, assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, xsd_config_gateway: xsd_config)
      use_case.execute
    end

    let(:data) do
      ActiveRecord::Base.connection.exec_query("SELECT DISTINCT schema_version
        FROM assessment_attribute_lookups aal
        INNER JOIN assessment_lookups al on aal.lookup_id = al.id
        INNER JOIN assessment_attributes aa on aal.attribute_id = aa.attribute_id
        WHERE aa.attribute_name = 'construction_age_band' AND lookup_key = 'A' AND schema_version IN('SAP-Schema-16.3', 'SAP-Schema-17.1')
        ORDER BY schema_version")
    end

    it "returns values for SAP 16.3 and SAP 17" do
      expect(data.rows.flatten).to eq(%w[SAP-Schema-16.3 SAP-Schema-17.1])
    end
  end

  context "when saving transaction types for RdSAP" do
    let(:lookups_gateway) do
      Gateway::AssessmentLookupsGateway.new
    end

    let(:saved_data) do
      ActiveRecord::Base.connection.exec_query("SELECT lookup_key, lookup_value
                FROM assessment_lookups ")
    end

    before do
      lookups_gateway = Gateway::AssessmentLookupsGateway.new
      xsd_config = instance_double(Gateway::XsdConfigGateway)
      allow(xsd_config).to receive(:nodes_and_paths).and_return([{ "attribute_name" => "transaction_type",
                                                                   "type_of_assessment" => "RdSAP",
                                                                   "xsd_node_name" => "//Transaction-Type",
                                                                   "xsd_path" => "/api/schemas/xml/RdSAP**/RdSAP/ExternalDefinitions.xml",
                                                                   "node_hash" => { "Transaction-Code" => "Transaction-Text" } }])
      use_case = described_class.new(assessment_lookups_gateway: lookups_gateway, xsd_presenter: presenter, assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, xsd_config_gateway: xsd_config)
      use_case.execute
    end

    it "save the enums from the xml definitions" do
      result = saved_data.rows.to_h
      expectation = { "6" => "New dwelling", "1" => "Marketed sale", "2" => "Non-marketed sale", "8" => "Rental", "9" => "Assessment for Green Deal", "10" => "Following Green Deal", "11" => "FiT application", "12" => "RHI application", "13" => "ECO assessment", "5" => "None of the above", "14" => "Stock condition survey", "16" => "Grant scheme", "17" => "Non-grant scheme", "15" => "Re-mortgaging" }

      expect(result).to eq(expectation)
    end
  end

  context "when saving transaction types for SAP" do
    before do
      xsd_config = Gateway::XsdConfigGateway.new("spec/config/attribute_transaction_type_map.json")
      use_case = described_class.new(assessment_lookups_gateway: lookups_gateway, xsd_presenter: Presenter::Xsd.new, assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, xsd_config_gateway: xsd_config)
      use_case.execute
    end

    let(:lookups_gateway) do
      Gateway::AssessmentLookupsGateway.new
    end

    let(:attribute_name) do
      "transaction_type"
    end

    it "save the transaction type for all versions of SAP" do
      sap_schemas = %w[SAP-Schema-16.0 SAP-Schema-16.1 SAP-Schema-16.2 SAP-Schema-16.3 SAP-Schema-17.0 SAP-Schema-17.1 SAP-Schema-18.0.0 SAP-Schema-19.0.0 SAP-Schema-19.1.0 SAP-Schema-NI-17.3 SAP-Schema-NI-17.4 SAP-Schema-NI-18.0.0]
      expect(fetch_schemas(attribute_name:).sort).to eq sap_schemas
    end

    it "save the enums from the sap 16.1" do
      data = fetch_saved_data_by_schema_version(attribute_name:, schema_version: "SAP-Schema-16.1")
      result = data.each_with_object({}) do |row, hash|
        hash[row["lookup_key"].to_i] = row["lookup_value"]
      end
      expectation = {  1 => "Marketed sale",
                       2 => "Non-marketed sale",
                       5 => "None of the above",
                       6 => "New dwelling",
                       8 => "Rental",
                       9 => "Assessment for Green Deal",
                       10 => "Following Green Deal",
                       11 => "FiT application" }

      expect(result).to eq(expectation)
    end

    it "save the enums from the sap 17.0" do
      data = fetch_saved_data_by_schema_version(attribute_name:, schema_version: "SAP-Schema-17.0")
      result = data.each_with_object({}) do |row, hash|
        hash[row["lookup_key"].to_i] = row["lookup_value"]
      end
      expectation = {  1 => "Marketed sale",
                       2 => "Non-marketed sale",
                       5 => "None of the above",
                       6 => "New dwelling",
                       8 => "Rental",
                       9 => "Assessment for Green Deal",
                       10 => "Following Green Deal",
                       11 => "FiT application" }

      expect(result).to eq(expectation)
    end
  end

  context "when saving the energy tariff enums" do
    let(:lookups_gateway)  do
      Gateway::AssessmentLookupsGateway.new
    end

    before(:all) do
      lookups_gateway = Gateway::AssessmentLookupsGateway.new
      xsd_config = Gateway::XsdConfigGateway.new("spec/config/attribute_enum_energy_tariff.json")
      use_case = described_class.new(assessment_lookups_gateway: lookups_gateway, xsd_presenter: Presenter::Xsd.new, assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, xsd_config_gateway: xsd_config)
      use_case.execute
    end

    it "returns the expected RdSAP enum value for a '1'" do
      enum_value = ActiveRecord::Base.connection.exec_query("SELECT lookup_value
        FROM assessment_attribute_lookups aal
        INNER JOIN assessment_lookups al on aal.lookup_id = al.id
        INNER JOIN assessment_attributes aa on aal.attribute_id = aa.attribute_id
        WHERE aa.attribute_name = 'energy_tariff' and lookup_key = '1' and aal.type_of_assessment='RdSAP'").first["lookup_value"]
      expect(enum_value).to eq("dual")
    end

    it "returns the expected SAP enum value for a '1'" do
      enum_value = ActiveRecord::Base.connection.exec_query("SELECT lookup_value
        FROM assessment_attribute_lookups aal
        INNER JOIN assessment_lookups al on aal.lookup_id = al.id
        INNER JOIN assessment_attributes aa on aal.attribute_id = aa.attribute_id
        WHERE aa.attribute_name = 'energy_tariff' and lookup_key = '1' and aal.type_of_assessment='SAP'").first["lookup_value"]
      expect(enum_value).to eq("standard tariff")
    end
  end
end

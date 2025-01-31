describe UseCase::ImportEnums do
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

    it "receive the array and loop over it 4 times - once for each unique key" do
      use_case.execute
      expect(presenter).to have_received(:get_enums_by_type).exactly(1).times
      expect(gateway).to have_received(:add_lookup).exactly(4).times
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
      enum_value = lookups_gateway.get_value_by_key(attribute_name: "construction_age_band", lookup_key: "L", type_of_assessment: "RdSAP",
                                                    schema_version: "RdSAP-Schema-17.0")
      expect(enum_value).to eq("England and Wales: 2012 onwards")
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
        WHERE aa.attribute_name = 'construction_age_band' AND lookup_key = 'A' AND schema_version IN('SAP-Schema-16.3', 'SAP-Schema-17.1/SAP')
        ORDER BY schema_version")
    end

    it "returns values for SAP 16.3 and SAP 17" do
      expect(data.rows.flatten).to eq(%w[SAP-Schema-16.3 SAP-Schema-17.1/SAP])
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

  # context "when my test is running" do
  #   it "can parse the xml file" do
  #     simple_type = "//Transaction-Type"
  #     file_name = "/Users/barryhalper/code/communitiesuk/epb-data-warehouse/api/schemas/xml/RdSAP-Schema-21.0.0/RdSAP/ExternalDefinitions.xml"
  #     xpath = "//xs:simpleType[@name='#{simple_type}']//xs:enumeration"
  #     # expect{ REXML::Document.new(File.read(file_name))}.not_to raise_error
  #     doc = Nokogiri.XML(File.read(file_name)) { |config| config.huge.strict }
  #
  #
  #     expect(0).to eq 0
  #   end
  # end
end

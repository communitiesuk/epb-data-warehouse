require "parallel"

shared_context "when lodging XML" do
  def parse_xml_to_json(xml:, assessment_id:)
    export_config = XmlPresenter::Sap::Sap1900ExportConfiguration.new
    parse = lambda {
      parser = XmlPresenter::Parser.new(**export_config.to_args(sub_node_value: assessment_id))
      parser.parse(xml)
    }

    Parallel.map([0]) { |_|
      parse.call
    }.first
  end

  def parse_assessment(assessment_id:, schema_type:, type_of_assessment:, assessment_address_id: nil, type: "epc", different_fields: nil)
    assessment_address_id ||= "RRN-#{assessment_id}"
    meta_data = {
      "assessment_type" => type_of_assessment,
      "schema_type" => schema_type,
      "assessment_address_id" => assessment_address_id,
    }
    sample = Nokogiri.XML Samples.xml(schema_type, type)
    xml = sample.to_xml
    document = UseCase::ParseXmlCertificate.new.execute(xml:, assessment_id:, schema_type:)
    raise Boundary::NoData, "document" if document.empty?

    document.merge!(meta_data)
    document.merge!(different_fields) unless different_fields.nil?
    document
  end

  def add_assessment(assessment_id:, schema_type:, type_of_assessment:, type: "epc", assessment_address_id: "RRN-0000-0000-0000-0000-0000", different_fields: nil, add_heat_pump_data: true)
    meta_data_sample = {
      "assessment_type" => type_of_assessment,
      "opt_out" => false,
      "created_at" => "2021-07-21T11:26:28.045Z",
      "schema_type" => schema_type,
      "assessment_address_id" => assessment_address_id,
    }
    xml = Samples.xml(schema_type, type)

    document = parse_xml_to_json(xml:, assessment_id:)
    add_heat_pump_data(document) if add_heat_pump_data
    document.merge!(different_fields) unless different_fields.nil?
    document.merge!(meta_data_sample)
    Gateway::DocumentsGateway.new.add_assessment(assessment_id:, document:)
    add_assessment_country_id(assessment_id:, document:)
  end

  def add_assessment_eav(assessment_id:, schema_type:, type_of_assessment:, type: "epc", assessment_address_id: "RRN-0000-0000-0000-0000-0000", different_fields: nil)
    meta_data_sample = {
      "assessment_type" => type_of_assessment,
      "opt_out" => false,
      "created_at" => "2021-07-21T11:26:28.045Z",
      "schema_type" => schema_type,
      "assessment_address_id" => assessment_address_id,
    }

    xml_path = "RRN"
    if type == "cepc"
      xml_path = "//CEPC:RRN"
    elsif type.end_with? "sap"
      xml_path = "//SAP:RRN"
    end

    document = Nokogiri.XML Samples.xml(schema_type, type)
    rrn = document.at(xml_path)
    rrn.children = assessment_id unless rrn.nil?
    xml = document.to_xml

    certificate_data = UseCase::ParseXmlCertificate.new.execute(xml:, assessment_id:, schema_type:)
    certificate_data.merge!(different_fields.transform_keys(&:to_s)) unless different_fields.nil?
    certificate_data.merge!(meta_data_sample)
    Container.import_certificate_data_use_case.execute(assessment_id:, certificate_data:)
    add_assessment_country_id(assessment_id:, document: certificate_data)
  end

  def add_assessment_eav_and_search(assessment_id:, schema_type:, type_of_assessment:, type: "epc", assessment_address_id: "RRN-0000-0000-0000-0000-0000", different_fields: nil)
    meta_data_sample = {
      "assessment_type" => type_of_assessment,
      "opt_out" => false,
      "created_at" => "2021-07-21T11:26:28.045Z",
      "schema_type" => schema_type,
      "assessment_address_id" => assessment_address_id,
    }

    xml_path = "RRN"
    if type == "cepc"
      xml_path = "//CEPC:RRN"
    elsif type.end_with? "sap"
      xml_path = "//SAP:RRN"
    end

    document = Nokogiri.XML Samples.xml(schema_type, type)
    rrn = document.at(xml_path)
    rrn.children = assessment_id unless rrn.nil?
    xml = document.to_xml

    certificate_data = UseCase::ParseXmlCertificate.new.execute(xml:, assessment_id:, schema_type:)
    certificate_data.merge!(different_fields.transform_keys(&:to_s)) unless different_fields.nil?
    certificate_data.merge!(meta_data_sample)
    Container.import_certificate_data_use_case.execute(assessment_id:, certificate_data:)
    Gateway::AssessmentSearchGateway.new.insert_assessment(assessment_id:, document: certificate_data, country_id: certificate_data["country_id"])
    add_assessment_country_id(assessment_id:, document: certificate_data)
  end

  def add_assessment_country_id(assessment_id:, document:)
    country_id = case document["postcode"]
                 when /^BT/
                   4
                 when /^ML/
                   5
                 else
                   1
                 end
    Gateway::AssessmentsCountryIdGateway::AssessmentsCountryId.find_or_create_by(assessment_id:, country_id:)
  end

  def add_countries
    ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE countries RESTART IDENTITY CASCADE", "SQL")

    insert_sql = <<-SQL
            INSERT INTO countries(country_id, country_code, country_name, address_base_country_code)
            VALUES (1, 'ENG', 'England' ,'["E"]'::jsonb),
                   (2, 'EAW', 'England and Wales', '["E", "W"]'::jsonb),
                     (3, 'UKN', 'Unknown', '{}'::jsonb),
                    (4, 'NIR', 'Northern Ireland', '["N"]'::jsonb),
                    (5, 'SCT', 'Scotland', '["S"]'::jsonb),
            (6,'', 'Channel Islands', '["L"]'::jsonb),
                (7,'NR', 'Not Recorded', null)

    SQL
    ActiveRecord::Base.connection.exec_query(insert_sql, "SQL")
  end

  def add_heat_pump_data(document)
    document.merge!(
      { "transaction_type": 6,
        "main_heating":
          [{
            "description": "Ground source heat pump, underfloor, electric",
            "energy_efficiency_rating": 5,
            "environmental_efficiency_rating": 5,
          }] },
    )
  end

  def add_commercial_assessment
    add_assessment(assessment_id: "0000-0000-0000-0000-0003", schema_type: "CEPC-8.0.0", type_of_assessment: "CEPC", type: "cepc")
  end

  def add_ni_assessment(assessment_id:, different_fields:)
    add_assessment(assessment_id:, schema_type: "SAP-Schema-NI-18.0.0", type_of_assessment: "SAP", different_fields:)
  end

  def add_non_new_dwelling_sap(assessment_id:)
    add_assessment(assessment_id:, schema_type:  "SAP-Schema-19.0.0", type_of_assessment: "SAP", different_fields: {
      "transaction_type": 1,
    })
  end

  def add_assessment_out_of_date_range(assessment_id:)
    add_assessment(assessment_id:, schema_type:  "SAP-Schema-19.0.0", type_of_assessment: "SAP", different_fields: {
      "registration_date": "2023-01-08",
    })
  end

  def update_postcode(assessment_id, postcde)
    sql = <<-SQL
      UPDATE assessment_documents
      SET document = JSONB_SET(document, '{postcode}', '"#{postcde}"')
      WHERE assessment_id = $1
    SQL

    bindings = [
      ActiveRecord::Relation::QueryAttribute.new(
        "assessment_id",
        assessment_id,
        ActiveRecord::Type::String.new,
      ),
    ]

    ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)
  end

  def import_enums(config_path)
    config_gateway = Gateway::XsdConfigGateway.new(config_path)
    UseCase::ImportEnums.new(assessment_lookups_gateway: Gateway::AssessmentLookupsGateway.new, xsd_presenter: Presenter::Xsd.new, assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, xsd_config_gateway: config_gateway).execute
  end
end

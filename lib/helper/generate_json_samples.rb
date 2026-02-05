class Helper::GenerateJsonSamples
  def self.parse_assessment(xml:, assessment_id:, schema_type:, type:)
    meta_data = {
      "assessment_type" => assessment_type(schema_type:, type:),
      "schema_type" => schema_type,
      "assessment_address_id" => "UPRN-000000012457",
    }

    document = UseCase::ParseXmlCertificate.new.execute(xml: xml.to_xml, assessment_id:, schema_type:)
    document.merge!(meta_data)
    save_document(assessment_id:, certificate_data: document)
    assessment = redacted_json(assessment_id:)
    delete_rows(assessment_id:)
    update_keys(assessment)
  end

  def self.update_keys(hash)
    JSON.parse(hash.to_json)
  end

  def self.assessment_type(schema_type:, type:)
    schema = schema_type.split("-")[0]
    case schema
    when "CEPC"
      type.gsub("+rr", "").upcase
    when "RdSAP"
      "RdSAP"
    else
      type == "epc" ? schema : type.upcase.tr("D", "d")
    end
  end

  def self.redacted_json(assessment_id:)
    Container.documents_gateway.fetch_by_id(assessment_id:)
  end

  def self.delete_rows(assessment_id:)
    sql = "DELETE FROM assessment_documents WHERE assessment_id ='#{assessment_id}'"
    ActiveRecord::Base.connection.exec_query(sql)
    sql = "DELETE  FROM assessment_search WHERE assessment_id ='#{assessment_id}'"
    ActiveRecord::Base.connection.exec_query(sql)
    nil
  end

  def self.save_document(assessment_id:, certificate_data:)
    Container.import_certificate_data_use_case.execute(assessment_id:, certificate_data:)
    Gateway::AssessmentSearchGateway.new.insert_assessment(assessment_id:, created_at: Time.now, document: certificate_data, country_id: 1)
  end

  def self.get_rrn(xml:, type:, schema_type:)
    is_commercial = type.include?("cepc") || type.include?("dec")
    version_number = schema_type.scan(/\d+/).first
    is_old_sap = schema_type.start_with?("SAP") && version_number == 16
    rrn = is_commercial || is_old_sap ? xml.at("//*[local-name() = 'RRN']").children : xml.at("RRN")
    rrn.to_s
  end

  def self.get_sample_files
    samples_dir = "#{Dir.pwd}/spec/fixtures/samples"
    sample_files = Dir.glob("#{samples_dir}/**/*.xml")
    rejected_files = %w[ac-cert redacted dec_exceeds 15 NI epc_sap_compliance]
    rejected_files.each do |i|
      sample_files.reject! { |f| f.include? i }
    end
    sample_files
  end

  private_class_method :save_document, :delete_rows, :assessment_type, :update_keys, :redacted_json
end

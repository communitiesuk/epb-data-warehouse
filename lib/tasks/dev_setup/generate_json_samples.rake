namespace :dev_setup do
  desc "convert each xml sample to redacted json format"
  task :generate_json_examples do
    Tasks::TaskHelpers.quit_if_production

    output_dir = "#{Dir.pwd}/spec/fixtures/json_samples"
    mkdir output_dir unless Dir.exist? output_dir

    sample_files = GenerateJsonSamples.get_sample_files
    sample_files.each do |file|
      arr = file.split("/")
      schema_type = arr[arr.size - 2]
      type = arr[arr.size - 1].gsub(".xml", "")
      xml = Nokogiri.XML Samples.xml(schema_type, type)
      assessment_id = GenerateJsonSamples.get_rrn(xml:, type:, schema_type:)
      redacted_json = GenerateJsonSamples.parse_assessment(xml:, assessment_id:, schema_type:, type:)
      new_dir_path =  "#{output_dir}/#{schema_type}"
      new_file_path = "#{new_dir_path}/#{type}.json"
      mkdir new_dir_path unless Dir.exist? new_dir_path
      File.delete new_file_path if File.exist? new_file_path

      File.open(new_file_path, "w") do |f|
        f.write(JSON.pretty_generate(redacted_json))
      end
    end
    puts "--XML Samples converted to redacted json format and written to #{output_dir}---"
  end
end

class GenerateJsonSamples
  def self.parse_assessment(xml:, assessment_id:, schema_type:, type:)
    assessment_address_id ||= "RRN-#{assessment_id}"
    meta_data = {
      "assessment_type" => type.gsub("+rr", "").upcase,
      "schema_type" => schema_type,
      "assessment_address_id" => assessment_address_id,
    }

    document = UseCase::ParseXmlCertificate.new.execute(xml: xml.to_xml, assessment_id:, schema_type:)
    document.merge!(meta_data)
    Domain::RedactedDocument.new(result: document.to_json).get_hash
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
    rejected_files = %w[ac-cert redacted dec_exceeds 15 NI]
    rejected_files.each do |i|
      sample_files.reject! { |f| f.include? i }
    end
    sample_files
  end
end

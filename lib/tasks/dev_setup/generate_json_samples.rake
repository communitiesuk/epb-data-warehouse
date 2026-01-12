require_relative "../../helper/generate_json_samples"

namespace :dev_setup do
  desc "convert each xml sample to redacted json format"
  task :generate_json_examples do
    Tasks::TaskHelpers.quit_if_production

    output_dir = "#{Dir.pwd}/spec/fixtures/json_samples"
    mkdir output_dir unless Dir.exist? output_dir

    sample_files = Helper::GenerateJsonSamples.get_sample_files
    sample_files.each do |file|
      arr = file.split("/")
      schema_type = arr[arr.size - 2]
      type = arr[arr.size - 1].gsub(".xml", "")
      xml = Nokogiri.XML Samples.xml(schema_type, type)
      assessment_id = Helper::GenerateJsonSamples.get_rrn(xml:, type:, schema_type:)
      redacted_json = Helper::GenerateJsonSamples.parse_assessment(xml:, assessment_id:, schema_type:, type:)
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

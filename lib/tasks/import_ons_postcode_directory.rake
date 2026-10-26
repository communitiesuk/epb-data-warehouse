# frozen_string_literal: true

RubyVM::YJIT.enable if defined? RubyVM::YJIT.enable

require "zip"
require "tempfile"
require "benchmark"

desc "Import ONS postcode data into the ons_postcode_directory tables"
task :import_ons_postcode_directory, %i[url] do |_, args|
  name_files = {
    "CTRY" => "Country",
    "LAD" => "Local authority",
    "PCON" => "Westminster parliamentary constituency",
    "RGN" => "Region",
  }

  raise "zip file url not supplied" unless args[:url]

  uri = URI(args[:url])

  Tempfile.create(anonymous: true) do |file|
    file.binmode

    time = Benchmark.realtime do
      catch :done do
        redirect_count = 0
        loop do
          Net::HTTP.get_response(uri) do |response|
            case response
            when Net::HTTPSuccess
              response.read_body { file.write(it) }
              throw :done
            when Net::HTTPRedirection
              redirect_count += 1
              raise "too many redirects" if redirect_count > 10

              uri = URI.join(uri, URI(response["location"]))
            else
              raise "unexpected http response: #{response.code} #{response.message} #{response.body}"
            end
          end
        end
      end

      file.rewind
    end

    puts "Downloaded zip (#{ActiveSupport::NumberHelper.number_to_human_size(file.size)}) in #{time.round(2)} seconds"

    raise "return file is empty" if file.size.zero? # rubocop:disable Style/ZeroLengthPredicate

    time = Benchmark.realtime do
      connection = ActiveRecord::Base.connection
      ActiveRecord::Base.transaction do
        connection.execute("TRUNCATE ons_postcode_directory, ons_postcode_directory_names RESTART IDENTITY")
        version_month = nil
        unprocessed_name_files = name_files.keys

        Zip::InputStream.open(file) do |zip_stream|
          while (entry = zip_stream.get_next_entry)
            case entry.name
            when %r{Data/ONSPD_(\w{3})_(\d{4})_UK\.csv\Z}
              # The version number we store in the database is the form yyyy-mm
              version_month = "#{Regexp.last_match.captures[1]}-#{Date::ABBR_MONTHNAMES.index(Regexp.last_match.captures[0].capitalize).to_s.rjust(2, '0')}"
              puts "Extracted version month and year: #{version_month}"

              raw_connection = connection.raw_connection
              raw_connection.copy_data(<<~SQL.squish, PG::TextEncoder::CopyRow.new) do
                COPY
                  ons_postcode_directory
                  (postcode, country_code, region_code, local_authority_code, westminster_parliamentary_constituency_code, other_areas)
                  FROM STDIN
              SQL
                # Using arrays instead of hashes - that is, not setting `headers: true` - substantially reduces object allocation and processing time
                csv = CSV.new(zip_stream, encoding: "UTF-8")
                headers = csv.shift
                pcds_index    = headers.index("pcds")
                country_index = headers.index("ctry26cd")
                region_index  = headers.index("rgn26cd")
                lad_index     = headers.index("lad26cd")
                pcon_index    = headers.index("pcon24cd")
                other_headers = headers.each_with_index.reject { |(_, i)| [pcds_index, country_index, region_index, lad_index, pcon_index].include?(i) }

                count = 0
                csv.each do |row|
                  count += 1
                  raw_connection.put_copy_data [
                    row[pcds_index].strip,
                    row[country_index],
                    row[region_index],
                    row[lad_index],
                    row[pcon_index],
                    JSON.generate(other_headers.to_h { |(k, i)| [k, row[i]] }),
                  ]
                end
                puts "Saved #{ActiveSupport::NumberHelper.number_to_delimited(count)} postcodes"
              end

            when %r{Documents/(#{Regexp.union(name_files.keys)}).*\.csv\Z}
              type = name_files[Regexp.last_match.captures[0]]
              unprocessed_name_files.delete(Regexp.last_match.captures[0])

              raw_connection = connection.raw_connection
              raw_connection.copy_data(<<~SQL.squish, PG::TextEncoder::CopyRow.new) do
                COPY
                  ons_postcode_directory_names
                  (area_code, name, type, type_code)
                  FROM STDIN
              SQL
                csv = CSV.new(zip_stream, encoding: "UTF-8")
                headers = csv.shift
                name_column_index = headers.index { it.end_with?("NM") }
                # Remove the BOM from the first header
                type_code = headers.first.downcase.force_encoding("UTF-8").delete_prefix!("\uFEFF")

                count = 0
                csv.each do |row|
                  next if row[0].nil?

                  count += 1
                  raw_connection.put_copy_data [row[0], row[name_column_index], type, type_code]
                end
                puts "Saved #{count} #{type} records"
              end
            end
          end
        end

        raise "data file not found" unless version_month
        raise "name files not found: #{unprocessed_name_files.join(', ')}" unless unprocessed_name_files.empty?

        connection.execute ActiveRecord::Base.sanitize_sql_array([<<~SQL, version_month])
          INSERT INTO ons_postcode_directory_versions (version_month, created_at, updated_at) VALUES (?, NOW(), NOW())
        SQL
      end
    end

    puts "Processed zip in #{time.round(2)} seconds"
  end
end

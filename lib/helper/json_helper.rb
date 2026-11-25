require "json-schema"

JSON::Validator.use_multi_json = false

module Helper
  module JsonHelper
    class << self
      def convert_to_ruby_hash(json_string, schema: false)
        begin
          json = JSON.parse(json_string)
        rescue JSON::ParserError => e
          raise Boundary::Json::ParseError, e.message
        end

        begin
          JSON::Validator.validate!(schema, json) if schema
        rescue JSON::Schema::ValidationError => e
          raise Boundary::Json::ValidationError.new(e.message, failed_properties: extract_failed_properties(schema:, json:))
        end

        json.deep_transform_keys { |k| k.to_s.underscore.to_sym }
      end

      def convert_to_json(hash)
        hash.as_json.deep_transform_keys { it.camelize(:lower) }.to_json
      end

    private

      def extract_failed_properties(schema:, json:)
        JSON::Validator.fully_validate(schema, json).map { it.scan(/'#\/([a-zA-Z]+)'/) }.flatten
      end
    end
  end
end

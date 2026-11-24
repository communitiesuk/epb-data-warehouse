require "json-schema"

JSON::Validator.use_multi_json = false
JSON::Validator.register_format_validator(
  "email",
  lambda do |value|
    unless value.include?("@")
      raise JSON::Schema::CustomFormatError, "Must be a valid email"
    end
  end,
)
JSON::Validator.register_format_validator(
  "iso-date",
  lambda do |value|
    Date.strptime(value, "%Y-%m-%d")
  rescue StandardError
    raise JSON::Schema::CustomFormatError,
          "Must be date in format YYYY-MM-DD"
  end,
)
JSON::Validator.register_format_validator(
  "positive-int",
  lambda do |value|
    if value.negative?
      raise JSON::Schema::CustomFormatError, "Must be a positive number"
    end
  end,
)
JSON::Validator.register_format_validator(
  "telephone",
  lambda do |value|
    if value.size > 256
      raise JSON::Schema::CustomFormatError, "Must be less than 257 chars"
    end
  end,
)

module Helper
  module JsonHelper
    extend self

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

  private

    def extract_failed_properties(schema:, json:)
      JSON::Validator.fully_validate(schema, json).map { |message|
        message.scan(/'#\/([a-zA-Z]+)'/)
      }.flatten
    rescue StandardError
      []
    end
  end
end

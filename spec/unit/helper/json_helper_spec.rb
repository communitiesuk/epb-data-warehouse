# frozen_string_literal: true

describe Helper::JsonHelper do
  let(:helper) { described_class }

  describe ".convert_to_ruby_hash" do
    it "changes top level keys to symbols" do
      result = helper.convert_to_ruby_hash({ "foo" => "Bar" }.to_json)
      expect(result.keys).to include(:foo)
    end

    it "changes nested keys to symbols" do
      result =
        helper.convert_to_ruby_hash({ "foo" => { "bar" => "baz" } }.to_json)
      expect(result[:foo].keys).to include(:bar)
    end

    it "changes top level keys to snake case" do
      result = helper.convert_to_ruby_hash({ "fooBar" => "baz" }.to_json)
      expect(result.keys).to include(:foo_bar)
    end

    it "changes nested level keys to snake case" do
      result = helper.convert_to_ruby_hash({ "fooBar" => { "barBaz" => "boo" } }.to_json)
      expect(result.keys).to include(:foo_bar)
      expect(result[:foo_bar].keys).to include(:bar_baz)
    end

    it "throws an error when validation doesnt match type" do
      schema = { type: "object", required: "firstName" }
      expect { helper.convert_to_ruby_hash("4", schema:) }.to raise_error Boundary::Json::ValidationError
    end

    it "throws an error with invalid json" do
      schema = { type: "object", required: "firstName" }
      expect { helper.convert_to_ruby_hash("{ invalid:", schema:) }.to raise_error Boundary::Json::ParseError
    end

    context "when there is a known property error in the schema" do
      let(:schema) do
        {
          oneOf: [
            {
              type: "object",
              required: %w[postcode other],
              properties: {
                postcode: {
                  type: "string",
                  pattern: "^[a-zA-Z0-9 ]{4,10}$",
                },
                other: {
                  type: "string",
                  minLength: 1,
                },
              },
            },
            {
              type: "object",
              required: %w[xyzzy],
              properties: {
                uprn: {
                  type: "string",
                },
              },
            },
          ],
        }.freeze
      end

      it "extracts the failed property when just the postcode fails" do
        expect {
          helper.convert_to_ruby_hash('{"postcode":"A0","other":"42"}', schema:)
        }.to raise_error(Boundary::Json::ValidationError) do |error|
          expect(error.failed_properties).to eq %w[postcode]
        end
      end

      it "extracts both properties when two fail" do
        expect {
          helper.convert_to_ruby_hash('{"postcode":"A0","other":""}', schema:)
        }.to raise_error(Boundary::Json::ValidationError) do |error|
          expect(error.failed_properties).to eq %w[other postcode]
        end
      end
    end
  end

  describe ".convert_to_json" do
    it "changes top level keys to strings" do
      result = helper.convert_to_json({ foo: "bar" })
      expect(JSON.parse(result).keys).to include("foo")
    end

    it "changes nested keys to strings" do
      result = helper.convert_to_json({ foo: { bar: "baz" } })
      expect(JSON.parse(result)["foo"].keys).to include("bar")
    end

    it "changes top level keys to camel case" do
      result = helper.convert_to_json({ foo_bar: "baz" })
      expect(JSON.parse(result).keys).to include("fooBar")
    end

    it "changes nested level keys to camel case" do
      result = helper.convert_to_json({ foo_bar: { bar_baz: "boo" } })
      expect(JSON.parse(result).keys).to include("fooBar")
      expect(JSON.parse(result)["fooBar"].keys).to include("barBaz")
    end
  end
end

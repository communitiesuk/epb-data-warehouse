module Domain
  class RedactedDocument
    def initialize(result:)
      @result = result
    end

    def to_hash
      {
        assessment_id: @result["assessment_id"],
        document: redact_json(@result["document"]),
      }
    end

    def get_hash
      redact JSON.parse(@result, symbolize_names: true)
    end

  private

    def redact_json(document)
      document = JSON.parse(document, symbolize_names: true).to_hash
      redact(document)
      document.to_json
    end

    def redact(document)
      document.delete(:scheme_assessor_id)
      document.delete(:equipment_owner)
      document.delete(:equipment_operator)
      document.delete(:owner)
      document.delete(:occupier)
      document
    end
  end
end

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

  private

    def redact_json(document)
      document = JSON.parse(document).to_hash
      document.delete("scheme_assessor_id")
      document.delete("equipment_owner")
      document.delete("equipment_operator")
      document.delete("owner")
      document.delete("occupier")
      document.to_json
    end
  end
end

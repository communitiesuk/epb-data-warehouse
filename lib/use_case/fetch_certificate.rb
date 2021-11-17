# frozen_string_literal: true

module UseCase
  class FetchCertificate < UseCase::FetchBase
    def execute(assessment_id)
      @gateway.fetch(assessment_id.strip)
    rescue Errors::AssessmentDoesNotExist
      # this might be replaced by a logger object
      puts "The assessment #{assessment_id} could not be found on the register."
    end
  end
end

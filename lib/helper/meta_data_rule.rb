module Helper
  module MetaDataRule
    def should_exclude(meta_data:)
      meta_data[:typeOfAssessment] == "AC-REPORT"
    end
  end
end

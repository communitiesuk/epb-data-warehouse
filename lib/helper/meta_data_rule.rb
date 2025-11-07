module Helper
  module MetaDataRule
    def is_cancelled?(meta_data:)
      !(meta_data[:cancelledAt].nil? && meta_data[:notForIssueAt].nil?)
    end

    def is_green_deal?(meta_data:)
      meta_data[:greenDeal] == true
    end

    def should_exclude?(meta_data:)
      meta_data[:typeOfAssessment] == "AC-REPORT"
    end
  end
end

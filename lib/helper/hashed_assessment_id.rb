module Helper
  module HashedAssessmentId
    def self.hash_rrn(rrn)
      rrn_array = rrn.split("-")
      rrn_array.unshift(rrn_array.last)
      rrn_array << rrn_array[1]
      Digest::SHA256.hexdigest rrn_array.join("-")
    end
  end
end

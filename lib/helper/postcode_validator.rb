module Helper
  class PostcodeValidator
    UK_POSTCODE_REGEX = /
      ^
      (
        ([Gg][Ii][Rr]\s?0[Aa]{2}) |
        (
          (
            ([A-Za-z][0-9]{1,2}) |
            ([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2}) |
            ([A-Za-z][0-9][A-Za-z]) |
            ([A-Za-z][A-Ha-hJ-Yj-y][0-9]?[A-Za-z])
          )
          \s?
          [0-9][A-Za-z]{2}
        )
      )
      $
    /x
    def self.validate(postcode)
      # converts everything into uppercase and removes all whitespaces
      stripped = postcode.upcase.gsub(/\s+/, "")

      # adds a space before last 3 characters
      formatted = "#{stripped[0...-3]} #{stripped[-3..]}"

      # validates the formatted postcode against the UK postcode regex
      unless formatted.match?(UK_POSTCODE_REGEX)
        raise Errors::PostcodeNotValid
      end

      formatted
    end
  end
end

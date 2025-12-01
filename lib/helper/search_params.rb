module Helper
  class SearchParams
    def self.validate(*args)
      this_args = args[0]

      unless this_args[:date_start].nil? || this_args[:date_end].nil?
        begin
          Date.parse(this_args[:date_start])
          Date.parse(this_args[:date_end])
        rescue Date::Error
          raise Boundary::InvalidDates
        end
        start_date = Date.parse(this_args[:date_start]) unless this_args[:date_start].nil?
        end_date = Date.parse(this_args[:date_end]) unless this_args[:date_end].nil?
        raise Boundary::InvalidDates if start_date > end_date
        raise Boundary::InvalidArgument, "date range includes today" if end_date >= Date.today
      end

      this_args[:postcode] = Helper::PostcodeValidator.validate(this_args[:postcode]) unless this_args[:postcode].nil?

      if !this_args[:uprn].nil? && this_args[:uprn].to_i.zero?
        raise Boundary::InvalidArgumentType, "uprn should be an integer great than 0"
      end

      unless this_args[:council].nil?
        councils = Container.ons_gateway.councils.map { |c| c["name"] }
        this_args[:council].each do |council|
          raise Errors::CouncilNotFound, "provide valid council name(s)" unless councils.include?(council)
        end
      end

      unless this_args[:constituency].nil?
        constituencies = Container.ons_gateway.constituencies.map { |c| c["name"] }
        this_args[:constituency].each do |constituency|
          raise Errors::ConstituencyNotFound, "provide valid constituency name(s)" unless constituencies.include?(constituency)
        end
      end

      raise Errors::OutOfPageSizeRangeError if this_args[:row_limit] < 1 || this_args[:row_limit] > 5000
    end

    def self.title_case(input)
      return nil if input.nil? || input.empty?

      arr = []
      input.each do |i|
        arr << i.split(" ").map { |word| word.match?(/and/i) ? word.downcase : word.capitalize }.join(" ")
      end
      arr
    end

    def self.format_band(input)
      return nil if input.nil? || input.empty?

      input.map(&:capitalize)
    end
  end
end

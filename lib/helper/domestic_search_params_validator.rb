module Helper
  class DomesticSearchParamsValidator
    def self.validate(*args)
      this_args = args[0]

      start_date = Date.parse(this_args[:date_start])
      end_date = Date.parse(this_args[:date_end])

      raise Boundary::InvalidDates if start_date > end_date

      raise Boundary::InvalidArgument, "date range includes today" if end_date >= Date.today

      this_args[:postcode] = Helper::PostcodeValidator.validate(this_args[:postcode]) unless this_args[:postcode].nil?

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
  end
end

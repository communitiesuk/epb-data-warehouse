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
        council = this_args[:council].clone
        lower_councils = Container.ons_gateway.councils.map { |c| c[:lower_name] }
        begin
          validate_name(ons_data_lower: lower_councils, arg: council)
          this_args[:council] = title_case(council, Container.ons_gateway.councils)
        rescue Errors::InvalidName
          raise Errors::CouncilNotFound, "provide valid council name(s)"
        end
      end

      unless this_args[:constituency].nil?
        constituency = this_args[:constituency].clone
        lower_constituencies = Container.ons_gateway.constituencies.map { |c| c[:lower_name] }
        begin
          validate_name(ons_data_lower: lower_constituencies, arg: constituency)
          this_args[:constituency] = title_case(constituency, Container.ons_gateway.constituencies)
        rescue Errors::InvalidName
          raise Errors::ConstituencyNotFound, "provide valid constituency name(s)"
        end
      end

      raise Errors::OutOfPageSizeRangeError if this_args[:row_limit] < 1 || this_args[:row_limit] > 5000

      this_args
    end

    def self.title_case(input, data)
      return nil if input.nil? || input.empty?

      arr = []
      input.each do |i|
        arr << data.find { |row| row[:lower_name] == i.downcase }[:name]
      end
      arr
    end

    def self.format_band(input)
      return nil if input.nil? || input.empty?

      input.map(&:capitalize)
    end

    def self.validate_name(ons_data_lower:, arg:)
      arg.each do |input|
        raise Errors::InvalidName unless ons_data_lower.include?(input.downcase)
      end
    end

    def self.clean_address(address)
      address.to_s.downcase.gsub(/[^a-zA-Z0-9\s]/, "").squish
    end
  end
end

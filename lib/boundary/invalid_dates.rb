module Boundary
  class InvalidDates < Boundary::TerminableError
    def initialize
      super(<<~MSG.strip)
        start date cannot be greater than end date
      MSG
    end
  end
end

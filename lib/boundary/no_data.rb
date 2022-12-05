module Boundary
  class NoData < Boundary::TerminableError
    def initialize(argument)
      super(<<~MSG.strip)
        There is no data return for '#{argument}'
      MSG
    end
  end
end

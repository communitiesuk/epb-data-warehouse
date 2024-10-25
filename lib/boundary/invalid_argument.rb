module Boundary
  class InvalidArgument < Boundary::TerminableError
    def initialize(argument)
      super(<<~MSG.strip)
        Invalid argument-: #{argument}
      MSG
    end
  end
end

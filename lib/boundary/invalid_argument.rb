module Boundary
  class InvalidArgument < Boundary::TerminableError
    def initialize(error_message)
      super(<<~MSG.strip)
        #{error_message}
      MSG
    end
  end
end

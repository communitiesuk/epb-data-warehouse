module Boundary
  class InvalidArgumentType < Boundary::TerminableError
    def initialize(error_message)
      super(<<~MSG.strip)
        #{error_message}
      MSG
    end
  end
end

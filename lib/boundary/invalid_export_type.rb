module Boundary
  class InvalidExportType < Boundary::TerminableError
    def initialize
      super(<<~MSG.strip)
        Missing 'type of export' environment variable
      MSG
    end
  end
end

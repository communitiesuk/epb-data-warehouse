module Boundary
  class EnumImportError < StandardError
    def initialize(node_name, message)
      super(<<~MSG.strip)
        Unable to import attribute #{node_name} : #{message}
      MSG
    end
  end
end

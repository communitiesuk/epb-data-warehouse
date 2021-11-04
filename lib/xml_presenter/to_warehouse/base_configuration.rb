module XmlPresenter
  module ToWarehouse
    class BaseConfiguration
      def to_args
        self.class.args
      end

      class << self
        KEYS = %i[excludes includes bases preferred_keys list_nodes rootless_list_nodes].freeze

        KEYS.each do |key|
          define_method key do |arg|
            args[key] = arg
          end
        end

        def args
          @args ||= {}
        end
      end
    end
  end
end

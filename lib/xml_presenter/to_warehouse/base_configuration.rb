module XmlPresenter
  module ToWarehouse
    class BaseConfiguration
      def to_args(sub_node_value: nil)
        self.class.args.merge(
          { specified_report: self.class.root_node_option(sub_node_value:) },
        ).compact
      end

      class << self
        KEYS = %i[excludes includes bases preferred_keys list_nodes rootless_list_nodes ignored_attributes nodes_ignoring_attributes].freeze

        KEYS.each do |key|
          define_method key do |arg|
            args[key] = arg
          end
        end

        def pick_root_node(root_node:, sub_node:)
          @root_node_partial_option = {
            root_node:,
            sub_node:,
          }
        end

        def root_node_option(sub_node_value:)
          if @root_node_partial_option && sub_node_value
            @root_node_partial_option.merge({ sub_node_value: })
          end
        end

        def args
          @args ||= {}
        end
      end
    end
  end
end

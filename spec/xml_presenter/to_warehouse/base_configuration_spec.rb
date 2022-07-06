class ExampleConfig < XmlPresenter::ToWarehouse::BaseConfiguration
  excludes %w[Exclude-1 Exclude-2]
  includes %w[Include-1 Include-2]
  bases %w[Base-1 Base-2 Base-3]
  preferred_keys({ "Outdated-Term" => "newfangled_term" })
  list_nodes %w[List-1 List-2]
  rootless_list_nodes({ "A-Random-List-Item" => "random_list" })
  pick_root_node root_node: "My-Root", sub_node: "Id-Node"
  ignored_attributes %w[ignored]
end

RSpec.describe XmlPresenter::ToWarehouse::BaseConfiguration do
  context "when no sub node index is passed" do
    specify "#to_args" do
      expected_args = {
        excludes: %w[Exclude-1 Exclude-2],
        includes: %w[Include-1 Include-2],
        bases: %w[Base-1 Base-2 Base-3],
        preferred_keys: { "Outdated-Term" => "newfangled_term" },
        list_nodes: %w[List-1 List-2],
        rootless_list_nodes: { "A-Random-List-Item" => "random_list" },
        ignored_attributes: %w[ignored],
      }
      expect(ExampleConfig.new.to_args).to eq expected_args
    end
  end

  context "when a sub node index is passed" do
    let(:sub_node_value) { "the sub node value we are looking for" }

    specify "#to_args" do
      expected_args = {
        excludes: %w[Exclude-1 Exclude-2],
        includes: %w[Include-1 Include-2],
        bases: %w[Base-1 Base-2 Base-3],
        preferred_keys: { "Outdated-Term" => "newfangled_term" },
        list_nodes: %w[List-1 List-2],
        rootless_list_nodes: { "A-Random-List-Item" => "random_list" },
        specified_report: { root_node: "My-Root", sub_node: "Id-Node", sub_node_value: },
        ignored_attributes: %w[ignored],
      }
      expect(ExampleConfig.new.to_args(sub_node_value:)).to eq expected_args
    end
  end
end

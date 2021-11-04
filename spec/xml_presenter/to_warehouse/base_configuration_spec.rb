class ExampleConfig < XmlPresenter::ToWarehouse::BaseConfiguration
  excludes %w[Exclude-1 Exclude-2]
  includes %w[Include-1 Include-2]
  bases %w[Base-1 Base-2 Base-3]
  preferred_keys({ "Outdated-Term" => "newfangled_term" })
  list_nodes %w[List-1 List-2]
  rootless_list_nodes({ "A-Random-List-Item" => "random_list" })
end

RSpec.describe XmlPresenter::ToWarehouse::BaseConfiguration do
  specify "#to_args" do
    expected_args = {
      excludes: %w[Exclude-1 Exclude-2],
      includes: %w[Include-1 Include-2],
      bases: %w[Base-1 Base-2 Base-3],
      preferred_keys: { "Outdated-Term" => "newfangled_term" },
      list_nodes: %w[List-1 List-2],
      rootless_list_nodes: { "A-Random-List-Item" => "random_list" },
    }
    expect(ExampleConfig.new.to_args).to eq expected_args
  end
end

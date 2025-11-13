require "rspec/core" unless defined?(RSpec)

describe "DomesticController" do
  include_context "when requesting a search endpoint", "domestic"

  it_behaves_like "a search API endpoint", type: "domestic"
  it_behaves_like "a count API endpoint", type: "domestic"
end

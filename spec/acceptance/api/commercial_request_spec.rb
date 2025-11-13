require "rspec/core" unless defined?(RSpec)

describe "CommercialController" do
  include_context "when requesting a search endpoint", "non-domestic"

  it_behaves_like "a search API endpoint", type: "non-domestic"
  it_behaves_like "a count API endpoint", type: "non-domestic"
end

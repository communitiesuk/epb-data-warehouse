require "rspec/core" unless defined?(RSpec)

describe "DecController" do
  include_context "when requesting a search endpoint", "dec"

  it_behaves_like "a search API endpoint", type: "dec"
  it_behaves_like "a count API endpoint", type: "dec"
end

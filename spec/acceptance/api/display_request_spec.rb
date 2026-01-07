require "rspec/core" unless defined?(RSpec)

describe "DisplayController" do
  include_context "when requesting a search endpoint", "dec"

  it_behaves_like "a search API endpoint", type: "display"
  it_behaves_like "a count API endpoint",  type: "display"
end

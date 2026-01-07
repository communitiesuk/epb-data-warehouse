require "rspec/core" unless defined?(RSpec)

describe "FileController" do
  include RSpecDataWarehouseApiServiceMixin

  it_behaves_like "a file download API endpoint", file_name: "domestic", type: "csv"
  it_behaves_like "a file download API endpoint", file_name: "domestic", type: "json"
  it_behaves_like "a file download API endpoint", file_name: "non-domestic", type: "csv"
  it_behaves_like "a file download API endpoint", file_name: "non-domestic", type: "json"
  it_behaves_like "a file download API endpoint", file_name: "non-domestic-recommendations", type: "json"
  it_behaves_like "a file download API endpoint", file_name: "display", type: "csv"
  it_behaves_like "a file download API endpoint", file_name: "display", type: "json"
  it_behaves_like "a file download API endpoint", file_name: "display-recommendations", type: "json"

  it_behaves_like "a file info API endpoint", file_name: "domestic", type: "csv"
  it_behaves_like "a file info API endpoint", file_name: "domestic", type: "json"
  it_behaves_like "a file info API endpoint", file_name: "non-domestic", type: "csv"
  it_behaves_like "a file info API endpoint", file_name: "non-domestic", type: "json"
  it_behaves_like "a file info API endpoint", file_name: "non-domestic-recommendations", type: "json"
  it_behaves_like "a file download API endpoint", file_name: "display", type: "csv"
  it_behaves_like "a file download API endpoint", file_name: "display", type: "json"
  it_behaves_like "a file download API endpoint", file_name: "display-recommendations", type: "json"
end

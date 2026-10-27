# frozen_string_literal: true

require "benchmark"

RSpec.describe "import_ons_postcode_directory" do
  subject(:task) { get_task("import_ons_postcode_directory") }

  before(:context) { DatabaseCleaner.start }
  after(:context) { DatabaseCleaner.clean }

  it "truncates the tables and imports expected data" do
    stub_request(:get, "https://ons/data").to_return(status: 200, body: File.new("spec/fixtures/ons_data/ONSPD_TEST.zip"), headers: {})

    ActiveRecord::Base.connection.execute(<<~SQL)
      INSERT INTO ons_postcode_directory
        (postcode, country_code, region_code, local_authority_code, westminster_parliamentary_constituency_code, other_areas)
        VALUES
        ('AB1 1BA', 'a', 'b', 'c', 'd', '{}');
    SQL

    ActiveRecord::Base.connection.execute(<<~SQL)
      INSERT INTO ons_postcode_directory_names
        (id, area_code, name, type, type_code)
        VALUES
        (1, 'a', 'b', 'c', 'd');
    SQL

    allow(Benchmark).to receive(:realtime) do |&block|
      block.call
      0.1425
    end

    expect {
      task.invoke("https://ons/data")
    }.to output(<<~OUTPUT).to_stdout
      Downloaded zip (66.7 KB) in 0.14 seconds
      Saved 7 Country records
      Saved 9 Region records
      Saved 650 Westminster parliamentary constituency records
      Saved 361 Local authority records
      Extracted version month and year: 2026-08
      Saved 100 postcodes
      Processed zip in 0.14 seconds
    OUTPUT

    expect(ActiveRecord::Base.connection.execute(<<~SQL).to_a).to match_snapshot("ons_postcode_directory")
      SELECT * FROM ons_postcode_directory
    SQL

    expect(ActiveRecord::Base.connection.execute(<<~SQL).to_a).to match_snapshot("ons_postcode_directory_names")
      SELECT * FROM ons_postcode_directory_names
    SQL

    expect(ActiveRecord::Base.connection.execute(<<~SQL).to_a).to eq [{ "version_month" => "2026-08" }]
      SELECT version_month FROM ons_postcode_directory_versions ORDER BY created_at LIMIT 1
    SQL
  end

  it "follows redirects" do
    stub_request(:get, "https://ons/redirect").to_return(status: 304, headers: { location: "/data" })
    stub_request(:get, "https://ons/data").to_return(status: 200, body: File.new("spec/fixtures/ons_data/ONSPD_TEST.zip"), headers: {})

    expect {
      task.invoke("https://ons/data")
    }.to output.to_stdout
  end

  it "errors if the url is not supplied" do
    expect { task.invoke }.to raise_error "zip file url not supplied"
  end

  it "errors if the downloaded file returns a non-200 status" do
    stub_request(:get, "https://ons/data").to_return(status: 500, body: "", headers: {})

    expect { task.invoke("https://ons/data") }.to raise_error "unexpected http response: 500  "
  end

  it "errors if the downloaded file responds with an infinite redirect loop" do
    stub_request(:get, "https://ons/data").to_return(status: 304, headers: { location: "https://ons/data" })

    expect { task.invoke("https://ons/data") }.to raise_error "too many redirects"
  end

  it "errors if the downloaded file is empty" do
    stub_request(:get, "https://ons/data").to_return(status: 200, body: "", headers: {})

    expect {
      expect {
        task.invoke("https://ons/data")
      }.to output.to_stdout
    }.to raise_error "return file is empty"
  end

  it "errors if the data file is missing" do
    stub_request(:get, "https://ons/data").to_return(status: 200, body: File.new("spec/fixtures/ons_data/ONSPD_TEST_MISSING_DATA.zip"), headers: {})

    expect {
      expect {
        task.invoke("https://ons/data")
      }.to output.to_stdout
    }.to raise_error "data file not found"
  end

  it "errors if a name file is missing" do
    stub_request(:get, "https://ons/data").to_return(status: 200, body: File.new("spec/fixtures/ons_data/ONSPD_TEST_MISSING_NAME.zip"), headers: {})

    expect {
      expect {
        task.invoke("https://ons/data")
      }.to output.to_stdout
    }.to raise_error "name files not found: PCON"
  end
end

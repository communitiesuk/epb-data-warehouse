require_relative "../../shared_context/shared_ons_data"

describe "ons_postcode_directory_names table" do
  # frozen_string_literal: true
  include_context "when saving ons data"

  before do
    import_postcode_directory_data
  end

  it "saves the data without errors" do
    expect { import_postcode_directory_name }.not_to raise_error
  end

  context "when inserting the same area code twice" do
    before do
      ActiveRecord::Base.connection.execute("TRUNCATE ons_postcode_directory_names")
      ActiveRecord::Base.connection.execute(sql)
    end

    let(:sql) do
      "INSERT INTO ons_postcode_directory_names(area_code,name,type,type_code)
              VALUES ('E12000077', 'Test Name', 'Region', 'rgn20c')"
    end

    it "raises a unique constraint error" do
      expect { ActiveRecord::Base.connection.execute(sql) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end
end

describe Helper::SearchParams, type: :helper do
  let(:search_arguments) do
    { date_start: "2023-12-01", date_end: "2023-12-23" }
  end

  describe "#validate" do
    context "when the inputs are valid" do
      it "does not raise for dates" do
        args = search_arguments.merge({ row_limit: 5000 })
        expect { described_class.validate(**args) }.not_to raise_error
      end

      it "does not raise and error for councils" do
        args = search_arguments.merge({ row_limit: 5000, council: ["WestminsteR", "Hammersmith And Fulham"] })
        expect(described_class.validate(**args)).to eq({ row_limit: 5000, council: ["Westminster", "Hammersmith and Fulham"], date_end: "2023-12-23", date_start: "2023-12-01" })
      end

      it "does not raise and error for constituencies" do
        args = search_arguments.merge({ row_limit: 5000, constituency: ["Chelsea and Fulham", "Cities of london and westminster"] })
        expect(described_class.validate(**args)).to eq({ row_limit: 5000, constituency: ["Chelsea and Fulham", "Cities of London and Westminster"], date_end: "2023-12-23", date_start: "2023-12-01" })
      end
    end

    context "when the postcode is passed without date" do
      it "does not raise an Inputs error" do
        args = { postcode: "SW1V 2SS", row_limit: 5000 }
        expect { described_class.validate(**args) }.not_to raise_error
      end
    end

    context "when the UPRN is passed without date" do
      it "does not raise an Inputs error" do
        args = { urpn: "100023336956", row_limit: 5000 }
        expect { described_class.validate(**args) }.not_to raise_error
      end
    end

    context "when the start date is before the end date" do
      it "raises an InvalidDates error" do
        search_arguments[:date_start] = "2023-12-24"
        search_arguments[:date_end] = "2023-12-23"
        expect { described_class.validate(**search_arguments) }.to raise_error(Boundary::InvalidDates)
      end
    end

    context "when the start date is invalid" do
      it "does not raises an InvalidDates error" do
        search_arguments[:date_start] = "2023-13-20"
        search_arguments[:date_end] = "2024-11-01"
        expect { described_class.validate(**search_arguments) }.to raise_error(Boundary::InvalidDates)
      end
    end

    context "when the end date is invalid" do
      it "does not raises an InvalidDates error" do
        search_arguments[:date_start] = "2023-11-20"
        search_arguments[:date_end] = "2023-11-31"
        expect { described_class.validate(**search_arguments) }.to raise_error(Boundary::InvalidDates)
      end
    end

    context "when the date range includes today" do
      it "raises an InvalidArgument error" do
        search_arguments[:date_start] = "2023-12-24"
        search_arguments[:date_end] = Date.today.strftime("%Y-%m-%d")
        expect { described_class.validate(**search_arguments) }.to raise_error(Boundary::InvalidArgument)
      end
    end

    context "when the postcode is invalid" do
      it "raises an PostcodeNotValid error" do
        search_arguments[:postcode] = "invalid postcode"
        expect { described_class.validate(**search_arguments) }.to raise_error(Errors::PostcodeNotValid)
      end
    end

    context "when the uprn is invalid" do
      it "raises an InvalidArgumentType error" do
        search_arguments[:uprn] = "invalid uprn"
        expect { described_class.validate(**search_arguments) }.to raise_error(Boundary::InvalidArgumentType)
      end
    end

    context "when the uprn is zero" do
      it "raises an InvalidArgumentType error" do
        search_arguments[:uprn] = "0"
        expect { described_class.validate(**search_arguments) }.to raise_error(Boundary::InvalidArgumentType)
      end
    end

    context "when the Council is invalid" do
      it "raises an CouncilNotFound error" do
        invalid_council_args = search_arguments.merge({ council: ["invalid council"] })
        expect { described_class.validate(**invalid_council_args) }.to raise_error(Errors::CouncilNotFound)
      end
    end

    context "when the Constituency is invalid" do
      it "raises an ConstituencyNotFound error" do
        invalid_council_args = search_arguments.merge({ constituency: ["invalid constituency"] })
        expect { described_class.validate(**invalid_council_args) }.to raise_error(Errors::ConstituencyNotFound)
      end
    end

    context "when the row limit is out of range" do
      it "raises an OutOfPageSizeRangeError error for less than 1" do
        args = search_arguments.merge({ row_limit: 0 })
        expect { described_class.validate(**args) }.to raise_error(Errors::OutOfPageSizeRangeError)
      end

      it "raises an OutOfPageSizeRangeError error for greater than 5000" do
        args = search_arguments.merge({ row_limit: 5001 })
        expect { described_class.validate(**args) }.to raise_error(Errors::OutOfPageSizeRangeError)
      end
    end
  end

  describe "#title_case" do
    let(:ons_data) do
      [{ name: "Bath and North East Somerset", lower_name: "bath and north east somerset" },
       { name: "Birmingham", lower_name: "birmingham" },
       { name: "Richmond upon Thames", lower_name: "richmond upon thames" },
       { name: "Blackburn with Darwen", lower_name: "blackburn with darwen" },
       { name: "Bristol, City of", lower_name: "bristol, city of" },
       { name: "Southend-on-Sea", lower_name: "southend-on-sea" },
       { name: "St. Helens", lower_name: "st. helens" },
       { name: "South Lanarkshire", lower_name: "south lanarkshire" },
       { name: "Hammersmith and Fulham", lower_name: "hammersmith and fulham" }]
    end

    context "when the input is in mixed case" do
      it "formats the inputs to the correct title case" do
        expect(described_class.title_case(%w[BIRMINGHAM], ons_data)).to eq(%w[Birmingham])
        expect(described_class.title_case(["BATH and north east somerset"], ons_data)).to eq(["Bath and North East Somerset"])
        expect(described_class.title_case(["BAtH And north east someRset"], ons_data)).to eq(["Bath and North East Somerset"])
        expect(described_class.title_case(["BAtH aNd north east someRset"], ons_data)).to eq(["Bath and North East Somerset"])
        expect(described_class.title_case(["Richmond Upon Thames"], ons_data)).to eq(["Richmond upon Thames"])
        expect(described_class.title_case(["BlackburN With Darwen"], ons_data)).to eq(["Blackburn with Darwen"])
        expect(described_class.title_case(["Bristol, City of"], ons_data)).to eq(["Bristol, City of"])
        expect(described_class.title_case(%w[Southend-on-Sea], ons_data)).to eq(%w[Southend-on-Sea])
        expect(described_class.title_case(["St. Helens"], ons_data)).to eq(["St. Helens"])
      end
    end

    context "when the input is nil" do
      it "does not error" do
        expect(described_class.title_case(nil, ons_data)).to be_nil
      end
    end

    context "when the input is empty" do
      it "does not error" do
        expect(described_class.title_case([], ons_data)).to be_nil
      end
    end

    context "when the input has more than one item" do
      expected = ["South Lanarkshire", "Hammersmith and Fulham"]
      param = ["south LANARKSHIRE", "hammersmith aNd Fulham"]
      it "updates the case of each array element" do
        expect(described_class.title_case(param, ons_data)).to eq(expected)
      end
    end
  end

  describe "#format_band" do
    context "when the input is in a mixed case" do
      it "formats the input to all be upper case" do
        expect(described_class.format_band(%w[c d])).to eq(%w[C D])
        expect(described_class.format_band(%w[c D])).to eq(%w[C D])
      end
    end

    context "when the input is nil" do
      it "does not error" do
        expect(described_class.format_band(nil)).to be_nil
      end
    end

    context "when the input is empty" do
      it "does not error" do
        expect(described_class.format_band([])).to be_nil
      end
    end
  end

  describe "#validate_name" do
    context "when the input is in uppercase" do
      let(:ons_data_lower) do
        ["westminster", "st. helens", "bath and north east somerset", "richmond upon thames", "kingston upon thames", "southend-on-sea", "bristol, city of"]
      end

      it "validate names" do
        arg = ["Westminster", "Kingston upon Thames", "Southend-on-Sea", "Bristol, City of"]
        expect { described_class.validate_name(ons_data_lower:, arg:) }.not_to raise_error
      end

      it "validate names regardless of case" do
        arg = ["westminster", "Kingston Upon Thames", "Southend-on-sea", "BATH and north east somerset"]
        expect { described_class.validate_name(ons_data_lower:, arg:) }.not_to raise_error
      end

      it "raises an error for any invalid name" do
        arg = %w[something Westminster]
        expect { described_class.validate_name(ons_data_lower:, arg:) }.to raise_error(Errors::InvalidName)
      end
    end
  end

  describe "#format_address" do
    context "when the input is in uppercase" do
      let(:address) { "1 Main Address Town SW1A 2AA" }

      it "return the input in lowercase" do
        expect(described_class.format_address(address)).to eq("1 main address town sw1a 2aa")
      end
    end

    context "when there are commas" do
      let(:address) { "1,2 Main Address, Town?, Steve's county! SW1A 2AA" }

      it "removes only the commas and replaces them with a space" do
        expect(described_class.format_address(address)).to eq("1 2 main address town? steve's county! sw1a 2aa")
      end
    end

    context "when the context has extra whitespace" do
      let(:address) { " 1 Main  Address       Town SW1A 2AA " }

      it "removes additional whitespaces" do
        expect(described_class.format_address(address)).to eq("1 main address town sw1a 2aa")
      end
    end
  end
end

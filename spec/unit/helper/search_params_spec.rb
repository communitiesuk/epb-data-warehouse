describe Helper::SearchParams, type: :helper do
  let(:search_arguments) do
    { date_start: "2023-12-01", date_end: "2023-12-23" }
  end

  describe "#validate" do
    context "when the dates are out of range" do
      it "raises an InvalidDates error" do
        search_arguments[:date_start] = "2023-12-24"
        search_arguments[:date_end] = "2023-12-23"
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
  end

  describe "#title_case" do
    context "when the input is in upper case" do
      it "formats the input to title case" do
        expect(described_class.title_case(%w[BIRMINGHAM])).to eq(%w[Birmingham])
      end
    end

    context "when the input is in mixed case" do
      it "formats the input to title case" do
        expect(described_class.title_case(["BATH and north east somerset"])).to eq(["Bath and North East Somerset"])
        expect(described_class.title_case(["BAtH And north east someRset"])).to eq(["Bath and North East Somerset"])
        expect(described_class.title_case(["BAtH aNd north east someRset"])).to eq(["Bath and North East Somerset"])
      end
    end

    context "when the input is nil" do
      it "does not error" do
        expect(described_class.title_case(nil)).to be_nil
      end
    end

    context "when the input is empty" do
      it "does not error" do
        expect(described_class.title_case([])).to be_nil
      end
    end

    context "when the input has more than one item" do
      expected = ["South Lanarkshire", "Hammersmith and Fulham"]
      param = ["south LANARKSHIRE", "hammersmith aNd Fulham"]
      it "updates the case of each array element" do
        expect(described_class.title_case(param)).to eq(expected)
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
end

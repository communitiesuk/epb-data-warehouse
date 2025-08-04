describe Helper::DomesticSearchParamsValidator, type: :helper do
  let(:search_arguments) do
    { date_start: "2023-12-01", date_end: "2023-12-23" }
  end

  context "when the dates are out of range" do
    it "raises an InvalidDates error" do
      search_arguments[:date_start] = "2023-12-24"
      search_arguments[:date_end] = "2023-12-23"
      expect { described_class.validate(**search_arguments) }.to raise_error(Boundary::InvalidDates)
    end
  end

  context "when the postcode is invalid" do
    it "raises an PostcodeNotValid error" do
      search_arguments[:postcode] = "invalid postcode"
      expect { described_class.validate(**search_arguments) }.to raise_error(Errors::PostcodeNotValid)
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

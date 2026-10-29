# frozen_string_literal: true

describe Helper::Rrn do
  it "formats a rrn with hypens" do
    expect(described_class.format("12345678910111213141")).to eq "1234-5678-9101-1121-3141"
  end

  it "formats a rrn without hypens" do
    expect(described_class.format("1234-5678-9101-1121-3141")).to eq "1234-5678-9101-1121-3141"
  end

  it "formats an incomplete rrn without erroring" do
    expect(described_class.format("123")).to eq "123"
  end
end

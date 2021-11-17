describe Container do
  it "checks all the factory methods can execute correctly" do
    described_class.methods(false).each do |method|
      expect { described_class.send method }.not_to raise_error
    end
  end
end

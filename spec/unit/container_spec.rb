describe Container do
  it "checks all the factory methods can execute correctly" do
    described_class.methods(false).each do |method|
      if method == :file_gateway
        expect { described_class.send(method, "my_file_name") }.not_to raise_error
      else
        expect { described_class.send method }.not_to raise_error
      end
    end
  end
end

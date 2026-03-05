describe "When testing PSL function fn_clean_descriptions" do
  context "when the description is JSON" do
    let(:json) do
      { "value": "High performance glazing", "language": "1" }.to_json
    end

    let(:stripped_description) do
      sql = "SELECT fn_clean_description('#{json}') as desc"
      result = ActiveRecord::Base.connection.exec_query(sql)
      result.first["desc"]
    end

    it "returns the value attribute" do
      expect(stripped_description).to eq("High performance glazing")
    end
  end

  context "when the description is a string with the language attribute" do
    let(:desc) do
      'Average thermal transmittance 0.15 W/m{"language" => "1", "value" => "\u00B2K"}'
    end


    let(:stripped_description) do
      sql = "SELECT fn_clean_description('#{desc}') as desc"
      result = ActiveRecord::Base.connection.exec_query(sql)
      result.first["desc"]
    end

    it "returns the value attribute" do
      expect(stripped_description).to eq("Average thermal transmittance 0.15 W/m")
    end
  end

  context "when the description is a string only" do
    let(:desc) do
      "From secondary system, waste water heat recovery"
    end

    let(:stripped_description) do
      sql = "SELECT fn_clean_description('#{desc}') as desc"
      result = ActiveRecord::Base.connection.exec_query(sql)
      result.first["desc"]
    end

    it "returns the value attribute" do
      expect(stripped_description).to eq("From secondary system, waste water heat recovery")
    end
  end
end

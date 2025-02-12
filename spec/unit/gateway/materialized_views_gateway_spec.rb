describe Gateway::MaterializedViewsGateway do
  subject(:gateway) { described_class.new }

  describe "#fetch_all" do
    subject(:fetch_all) { gateway.fetch_all }

    it "returns an array of one view name" do
      views = %w[mvw_avg_co2_emissions mvw_domestic_rr_search mvw_domestic_search]
      expect(fetch_all).to be_an(Array)
      expect(fetch_all.sort).to eq(views)
    end
  end

  describe "#refresh" do
    it "raises an error if the wrong view name is passed" do
      expect { gateway.refresh(name: "test") }.to raise_error Boundary::InvalidArgument
    end

    it "performs the refresh without the correct view name" do
      expect { gateway.refresh(name: "mvw_avg_co2_emissions") }.not_to raise_error
    end

    context "when passing concurrency to the method" do
      it "can refresh the view using the concurrency feature" do
        expect { gateway.refresh(name: "mvw_avg_co2_emissions", concurrently: true) }.not_to raise_error
      end
    end
  end
end

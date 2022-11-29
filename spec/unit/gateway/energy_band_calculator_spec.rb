shared_context "when using energy_band_calculator method" do
  def use_postgres_function(value, assessment_type)
    ActiveRecord::Base.connection.exec_query("SELECT energy_band_calculator(#{value}, '#{assessment_type}') as band")[0]["band"]
  end
end

describe "energy_band_calculator postgres function" do
  include_context "when using energy_band_calculator method"

  context "when getting domestic bands for SAP" do
    it "returns a band of A from  inputs greater than 91" do
      expect(use_postgres_function(92, "SAP")).to eq("A")
      expect(use_postgres_function(13_060, "SAP")).to eq("A")
    end

    it "returns a band of A from  inputs than 91 when SAP is lowercase" do
      expect(use_postgres_function(92, "sap")).to eq("A")
    end

    it "returns a band of B from a rating of 81" do
      expect(use_postgres_function(81, "SAP")).to eq("B")
    end

    it "returns a band of G from from inputs less than or equal to 20 " do
      expect(use_postgres_function(20, "SAP")).to eq("G")
      expect(use_postgres_function(-1, "SAP")).to eq("G")
    end

    context "when getting domestic bands for RdSAP" do
      it "returns a band of A for 103 " do
        expect(use_postgres_function(103, "RdSAP")).to eq("A")
      end

      it "returns a band of A from  inputs than 91 when RdSAP is incorrectly mixed case" do
        expect(use_postgres_function(92, "RDsap")).to eq("A")
      end

      it "returns a band of B from a rating of 81" do
        expect(use_postgres_function(81, "RdSAP")).to eq("B")
      end

      it "returns a band of G from from inputs less than or equal to 20 " do
        expect(use_postgres_function(20, "RdSAP")).to eq("G")
        expect(use_postgres_function(-1, "RdSAP")).to eq("G")
      end
    end

    context "when getting commercial bands for CEPC" do
      it "returns a band of A+ for a rating of -1" do
        expect(use_postgres_function(-1, "CEPC")).to eq "A+"
      end

      it "returns a band of A for a rating of 0" do
        expect(use_postgres_function(0, "CEPC")).to eq "A"
      end

      it "returns a band of B for a rating of 50" do
        expect(use_postgres_function(50, "CEPC")).to eq "B"
      end

      it "returns a band of G for a rating greater than 150" do
        expect(use_postgres_function(151, "CEPC")).to eq "G"
        expect(use_postgres_function(1510, "CEPC")).to eq "G"
      end

      context "when getting commercial bands for other commercial types" do
        it "returns a band of A+ for a rating of -1 for a DEC" do
          expect(use_postgres_function(-1, "DEC")).to eq "A+"
        end

        it "returns a band of A+ for a rating of -1 for a AC-REPORT" do
          expect(use_postgres_function(-1, "AC-REPORT")).to eq "A+"
        end
      end
    end
  end
end

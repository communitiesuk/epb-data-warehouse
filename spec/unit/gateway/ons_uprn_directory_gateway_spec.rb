describe Gateway::OnsUprnDirectoryGateway do
  subject(:gateway) { described_class.new }

  before do
    ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE ons_uprn_directory CASCADE;")
    ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE ons_uprn_directory_versions CASCADE;")
    ActiveRecord::Base.connection.reset_pk_sequence!("ons_uprn_directory_versions")
  end

  after do
    ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE ons_uprn_directory CASCADE;")
    ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE ons_uprn_directory_versions CASCADE;")
  end

  context "when registering a valid new version month" do
    context "when the month version does not already exist" do
      it "writes a version and returns the new ID as a symbol" do
        id = gateway.register_month("2022-01")

        expect(id).to eq :"1"
      end
    end

    context "when the month version already exists" do
      before do
        ActiveRecord::Base.connection.exec_query "INSERT INTO ons_uprn_directory_versions (version_month) VALUES ('2022-01')"
      end

      it "raises a version already exists error" do
        expect { gateway.register_month("2022-01") }.to raise_error described_class::VersionAlreadyExists
      end
    end
  end

  context "when registering an invalid month" do
    it "raises an invalid month error" do
      expect { gateway.register_month("November 2021") }.to raise_error described_class::InvalidMonth
    end
  end

  context "when deleting a month" do
    let(:month_count) { ActiveRecord::Base.connection.exec_query("SELECT COUNT(*) AS cnt FROM ons_uprn_directory_versions WHERE version_month='2022-01'").first["cnt"].to_i }

    before do
      ActiveRecord::Base.connection.exec_query "INSERT INTO ons_uprn_directory_versions (version_month) VALUES ('2022-01')"
    end

    it "successfully deletes the month" do
      gateway.delete_month "2022-01"

      expect(month_count).to eq 0
    end
  end

  context "when loading in a collection of UPRN directory records" do
    let(:record) do
      {
        uprn: "25098236",
        gridgb1e: "492209",
        gridgb1n: "240804",
        pcds: "MK16 0HZ",
        cty21cd: "E99999999",
        ced17cd: "E99999999",
        lad21cd: "E06000056",
        wd19cd: "E05008785",
        parncp19cd: "E04011940",
        hlth19cd: "E18000006",
        ctry191cd: "E92000001",
        rgn17cd: "E12000006",
        pcon18cd: "E14000813",
        eer17cd: "E15000006",
        ttwa15cd: "E30000166",
        itl21cd: "E06000056",
        npark16cd: "E99999999",
        oa11cd: "E00087852",
        lsoa11cd: "E01033194",
        msoa11cd: "E02003605",
        wz11cd: "E33025550",
        ccg19cd: "E38000010",
        bua11cd: "E34999999",
        buasd11cd: "E35999999",
        ruc11ind: "E1",
        oac11ind: "6A3",
        lep17cd1: "E37000041",
        lep17cd2: "",
        pfa19cd: "E23000026",
        imd19ind: "25006",
      }
    end

    let(:version_id) { gateway.register_month "2022-01" }

    context "with one data line provided" do
      it "writes correctly to the directory table", :aggregate_failures do
        gateway.insert_directory_data [record], version_id: version_id

        data_row = ActiveRecord::Base.connection.exec_query("SELECT * FROM ons_uprn_directory").first&.symbolize_keys

        expect(data_row).to include({
          uprn: "UPRN-000025098236",
          postcode: "MK16 0HZ",
        })
        expect(JSON.parse(data_row[:areas], symbolize_names: true)).to eq record.except(:uprn, :pcds)
      end
    end

    context "with thousands data lines provided" do
      let(:line_count) { 2345 }

      let(:records) do
        1.upto(line_count).map { record.tap { |h| h[:uprn] = rand(1_000_000).to_s } }
      end

      it "writes correct number of rows with the expected postcode and areas" do
        gateway.insert_directory_data records, version_id: version_id

        count = ActiveRecord::Base.connection.exec_query("SELECT COUNT(*) AS cnt FROM ons_uprn_directory WHERE postcode='#{record[:pcds]}' AND areas->>'bua11cd'='E34999999'").first["cnt"].to_i

        expect(count).to eq line_count
      end
    end
  end
end

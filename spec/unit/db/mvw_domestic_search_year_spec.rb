describe "MvwDomesticSearchYear" do
  let(:documents_gateway) { Gateway::DocumentsGateway.new }

  let(:assessment_search_gateway) { Gateway::AssessmentSearchGateway.new }

  let(:assessment_base_document) do
    {
      "schema_version_original" => "LIG-19.0",
      "sap_version" => 9.94,
      "calculation_software_name" => "Elmhurst Energy Systems RdSAP Calculator",
      "calculation_software_version" => "4.05r0005",
      "inspection_date" => "2020-06-01",
      "report_type" => 2,
      "status" => "entered",
      "language_code" => 1,
      "tenure" => 1,
      "transaction_type" => 1,
      "property_type" => 0,
      "scheme_assessor_id" => "EES/008538",
      "region_code" => 17,
      "country_code" => "EAW",
      "owner" => "Unknown",
      "occupier" => "William Gates",
      "assessment_type" => "RdSAP",
      "equipment_operator" => "some value",
    }
  end

  let(:assessment_2008_document) do
    assessment_base_document.merge({
      "assessment_id" => "1234-0000-0000-0000-2008",
      "registration_date" => "2008-06-01",
      "assessment_address_id" => "UPRN-0000000002008",
    })
  end

  let(:assessment_2012_document) do
    assessment_base_document.merge({
      "assessment_id" => "1234-0000-0000-0000-2012",
      "registration_date" => "2012-06-01",
      "assessment_address_id" => "UPRN-0000000002012",
    })
  end

  let(:assessment_2020_document) do
    assessment_base_document.merge({
      "assessment_id" => "1234-0000-0000-0000-2020",
      "registration_date" => "2020-06-01",
      "assessment_address_id" => "UPRN-0000000002020",
    })
  end

  let(:assessment_2026_document) do
    assessment_base_document.merge({
      "assessment_id" => "1234-0000-0000-0000-2026",
      "registration_date" => "2026-06-01",
      "assessment_address_id" => "UPRN-0000000002026",
    })
  end

  def fetch_mvw_certificate_numbers(year:)
    sql = "SELECT certificate_number FROM mvw_domestic_search_#{year}"
    result = ActiveRecord::Base.connection.exec_query(sql)
    result.rows
  end

  def insert_assessment(year:)
    assessment_id = "1234-0000-0000-0000-#{year}"
    documents_gateway.add_assessment(assessment_id:, document: send("assessment_#{year}_document"))
    assessment_search_gateway.insert_assessment(assessment_id:, document: send("assessment_#{year}_document"), country_id: 1)
    Gateway::AssessmentsCountryIdGateway::AssessmentsCountryId.find_or_create_by(assessment_id:, country_id: 1)
  end

  [2008, 2012, 2020, 2026].each do |year|
    context "when fetching assessments from mvw_domestic_search_#{year}" do
      before do
        insert_assessment(year:)
        Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_domestic_search_#{year}")
      end

      it "includes the assessment in the materialized view" do
        expect(fetch_mvw_certificate_numbers(year:).flatten).to eq(["1234-0000-0000-0000-#{year}"])
      end
    end
  end

  [2009, 2010, 2013].each do |year|
    context "when fetching from empty mvw_domestic_search_#{year}" do
      before do
        Gateway::MaterializedViewsGateway.new.refresh(name: "mvw_domestic_search_#{year}")
      end

      it "returns no data from the materialized view" do
        expect(fetch_mvw_certificate_numbers(year:).flatten).to eq([])
      end
    end
  end

  context "when checking that mvw_domestic_search materialized views exist in DB from 2008 until current year" do
    let(:current_year) { Time.now.year }

    let(:mvw_names) do
      sql = "SELECT matviewname
               FROM  pg_matviews
               WHERE matviewname LIKE 'mvw_domestic_search%'"
      ActiveRecord::Base.connection.exec_query(sql).rows.flatten
    end

    it "includes mvw_domestic_search materialized views for every year from 2008 to current year" do
      expected = (2008..current_year).map { |year| "mvw_domestic_search_#{year}" }
      missing = expected - mvw_names

      expect(missing).to eq([])
    end
  end
end

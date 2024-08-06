describe Gateway::AssessmentAttributesGateway do
  let(:gateway) { described_class.new }
  let(:attributes) do
    ActiveRecord::Base.connection.exec_query(
      "SELECT attribute_id, attribute_name FROM assessment_attributes",
    )
  end
  let(:attribute_values) do
    ActiveRecord::Base.connection.exec_query(
      "SELECT * FROM assessment_attribute_values",
    )
  end
  let(:json_blob) do
    { "schema_version_original" => "LIG-19.0",
      "sap_version" => 9.94,
      "calculation_software_name" => "Elmhurst Energy Systems RdSAP Calculator",
      "calculation_software_version" => "4.05r0005",
      "rrn" => "8570-6826-6530-4969-0202",
      "inspection_date" => "2020-06-01",
      "report_type" => 2,
      "completion_date" => "2020-06-01",
      "registration_date" => "2020-06-01",
      "status" => "entered",
      "language_code" => 1,
      "tenure" => 1,
      "transaction_type" => 1,
      "property_type" => 0,
      "scheme_assessor_id" => "EES/008538",
      "property" =>
                            { "address" =>
                               { "address_line_1" => "25, Marlborough Place",
                                 "post_town" => "LONDON",
                                 "postcode" => "NW8 0PG" },
                              "uprn" => 7_435_089_668 },
      "region_code" => 17,
      "country_code" => "EAW" }
  end

  before do
    ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE assessment_attributes CASCADE;")
    ActiveRecord::Base.connection.reset_pk_sequence!("assessment_attributes")
    described_class.reset!
    gateway.add_attribute(attribute_name: "test")
    gateway.add_attribute(attribute_name: "test1")
  end

  it "returns a row from the database for each inserted value" do
    expect(attributes.rows.length).to eq(2)
    expect(attributes.rows[0]).to eq([1, "test"])
    expect(attributes.rows[1]).to eq([2, "test1"])
  end

  it "does not return an additional row where a duplication has been entered" do
    expect(gateway.add_attribute(attribute_name: "test")).to eq(1)
    expect(attributes.rows.length).to eq(2)
  end

  it "can access the id of the insert regardless of whether it is created or not" do
    expect(gateway.add_attribute(attribute_name: "new one")).to eq(3)
  end

  it "inserts the attribute value into the database" do
    gateway.add_attribute_value(assessment_id: "0000-0000-0000-0000-0001", attribute_name: "a", attribute_value: "b")
    expect(attribute_values.rows.length).to eq(1)
    expect(attribute_values.first["assessment_id"]).to eq(
      "0000-0000-0000-0000-0001",
    )
    expect(attribute_values.first["attribute_value"]).to eq("b")
    expect(attribute_values.first["attribute_id"]).to eq(3)
    expect(attribute_values.first["attribute_value_int"]).to be_nil
    expect(attribute_values.first["attribute_value_float"]).to be_nil
  end

  context "when inserting a parent attribute name" do
    before do
      gateway.add_attribute(attribute_name: "attr_parent")
      gateway.add_attribute(attribute_name: "attr_parent", parent_name: "my_parent")
    end

    let(:attributes) do
      ActiveRecord::Base.connection.exec_query(
        "SELECT * FROM assessment_attributes WHERE attribute_name = 'attr_parent'",
      )
    end

    it "attribute table has a row for the same attribute" do
      expect(attributes.rows.count).to eq(2)
    end

    it "has a row that has the parent_name" do
      row = attributes.detect { |columns| columns["parent_name"] == "my_parent" }
      expect(row["parent_name"]).to eq("my_parent")
    end
  end

  context "when inserting an attribute with a numeric value that is out of integer range" do
    let(:stored_int) do
      ActiveRecord::Base.connection.exec_query(
        "SELECT attribute_value_int FROM assessment_attribute_values AS aav INNER JOIN assessment_attributes AS aa ON aa.attribute_id=aav.attribute_id WHERE assessment_id= '0000-0000-0000-0000-0001' AND attribute_name='out_of_range_numeric'",
      ).first["attribute_value_int"]
    end

    before do
      gateway.add_attribute_value(
        assessment_id: "0000-0000-0000-0000-0001",
        attribute_name: "out_of_range_numeric",
        attribute_value: "100041171491",
      )
    end

    it "does not store a numeric value as an integer that is out of range for a PostgreSQL integer data type" do
      expect(stored_int).to be_nil
    end
  end

  context "when inserting an attribute with a numeric value that is out of range but padded with zeroes" do
    let(:stored_int) do
      ActiveRecord::Base.connection.exec_query(
        "SELECT attribute_value_int FROM assessment_attribute_values AS aav INNER JOIN assessment_attributes AS aa ON aa.attribute_id=aav.attribute_id WHERE assessment_id= '0000-0000-0000-0000-0001' AND attribute_name='out_of_range_numeric'",
      ).first["attribute_value_int"]
    end

    before do
      gateway.add_attribute_value(
        assessment_id: "0000-0000-0000-0000-0001",
        attribute_name: "out_of_range_numeric",
        attribute_value: "002465160809",
      )
    end

    it "does not store a numeric value as an integer that is out of range for a PostgreSQL integer data type" do
      expect(stored_int).to be_nil
    end
  end

  context "when inserting an attribute with a value of 0 (zero)" do
    let(:stored_int) do
      ActiveRecord::Base.connection.exec_query(
        "SELECT attribute_value_int FROM assessment_attribute_values AS aav INNER JOIN assessment_attributes AS aa ON aa.attribute_id=aav.attribute_id WHERE assessment_id= '0000-0000-0000-0000-0001' AND attribute_name='zero'",
      ).first["attribute_value_int"]
    end

    before do
      gateway.add_attribute_value(
        assessment_id: "0000-0000-0000-0000-0001",
        attribute_name: "zero",
        attribute_value: 0,
      )
    end

    it "stores zero as an integer" do
      expect(stored_int).to eq 0
    end
  end

  context "when we insert many attributes for one assessment" do
    before do
      gateway.add_attribute_value(
        assessment_id: "0000-0000-0000-0000-0001",
        attribute_name: "construction_age_band",
        attribute_value: "England and Wales: 2007-2011",
      )
      gateway.add_attribute_value(
        assessment_id: "0000-0000-0000-0000-0001",
        attribute_name: "glazed_type",
        attribute_value: "test",
      )
      gateway.add_attribute_value(
        assessment_id: "0000-0000-0000-0000-0001",
        attribute_name: "current_energy_efficiency",
        attribute_value: "50",
      )

      gateway.add_attribute_value(
        assessment_id: "0000-0000-0000-0000-0001",
        attribute_name: "heating_cost_current",
        attribute_value: "365.98",
      )

      gateway.add_attribute_value(
        assessment_id: "0000-0000-0000-0000-0001",
        attribute_name: "json",
        attribute_value: json_blob,
      )
    end

    let(:assessment_attribute_values) do
      ActiveRecord::Base.connection.exec_query(
        "SELECT * FROM assessment_attribute_values WHERE assessment_id= '0000-0000-0000-0000-0001'
        ORDER BY attribute_id",
      )
    end

    it "returns a row for every attributes" do
      expect(assessment_attribute_values.rows.length).to eq(5)
    end

    it "row 3 will have a value in the integer column for the current_energy_efficiency" do
      expect(assessment_attribute_values[2]["attribute_value_int"]).to eq(50)
    end

    it "row 4 will have a value in the float column for the heating_cost_current" do
      expect(assessment_attribute_values[3]["attribute_value_int"]).to eq(
        365,
      )
      expect(assessment_attribute_values[3]["attribute_value_float"]).to eq(
        365.98,
      )
    end

    it "row 5 will have a json object in the json column" do
      result = JSON.parse(assessment_attribute_values[4]["json"])

      expect(result).to eq(json_blob)
    end

    describe "#get_attribute_id" do
      it "returns the relevant int value for an attribute string" do
        expect(gateway.get_attribute_id("glazed_type")).to eq(4)
      end
    end

    context "when extracting a single atttribute value for an assessment" do
      it "returns a row for every attributes" do
        expect(gateway.fetch_attribute_by_assessment(assessment_id: "0000-0000-0000-0000-0001", attribute: "construction_age_band")).to eq("England and Wales: 2007-2011")
      end
    end
  end

  context "when we insert the same attribute for many assessments" do
    before do
      gateway.add_attribute_value(
        assessment_id: "0000-0000-0000-0000-0001",
        attribute_name: "glazed_type",
        attribute_value: "another test",
      )
      gateway.add_attribute_value(
        assessment_id: "0000-0000-0000-0000-0002",
        attribute_name: "glazed_type",
        attribute_value: "test",
      )
    end

    it "the attribute table only increments by one" do
      expect(attributes.rows.length).to eq(3)
    end

    it "the attribute value table has two rows" do
      expect(attribute_values.rows.length).to eq(2)
    end
  end

  context "when we add multiple attributes for 3 assessments" do
    before do
      gateway.add_attribute_value(
        assessment_id: "0000-0000-0000-0000-0001",
        attribute_name: "construction_age_band",
        attribute_value: "England and Wales: 2007-2011",
      )
      gateway.add_attribute_value(
        assessment_id: "0000-0000-0000-0000-0001",
        attribute_name: "glazed_type",
        attribute_value: "test 1",
      )

      gateway.add_attribute_value(
        assessment_id: "0000-0000-0000-0000-0001",
        attribute_name: "heating_cost_current",
        attribute_value: "10.98",
      )

      gateway.add_attribute_value(
        assessment_id: "0000-0000-0000-0000-0002",
        attribute_name: "construction_age_band",
        attribute_value: "England: 1865",
      )

      gateway.add_attribute_value(
        assessment_id: "0000-0000-0000-0000-0002",
        attribute_name: "current_energy_efficiency",
        attribute_value: "40",
      )

      gateway.add_attribute_value(
        assessment_id: "0000-0000-0000-0000-0002",
        attribute_name: "heating_cost_current",
        attribute_value: "12.55",
      )

      gateway.add_attribute_value(
        assessment_id: "0000-0000-0000-0000-0003",
        attribute_name: "construction_age_band",
        attribute_value: "England and Wales: 1971-1987",
      )
      gateway.add_attribute_value(
        assessment_id: "0000-0000-0000-0000-0003",
        attribute_name: "glazed_type",
        attribute_value: "test 3",
      )

      gateway.add_attribute_value(
        assessment_id: "0000-0000-0000-0000-0003",
        attribute_name: "heating_cost_current",
        attribute_value: "9.45",
      )
    end

    let(:assessment_attribute_values) do
      ActiveRecord::Base.connection.exec_query(
        "SELECT * FROM assessment_attribute_values",
      )
    end

    it "returns 9 rows" do
      expect(assessment_attribute_values.rows.count).to eq(9)
    end

    context "when fetching the pivoted data" do
      let(:pivoted_data) do
        gateway.fetch_assessment_attributes(
          attribute_column_array: %w[construction_age_band glazed_type],
        )
      end

      it "has the correct number of rows, one for each assessment" do
        expect(pivoted_data.count).to eq(3)
      end

      it "has the correct assessments" do
        expect(pivoted_data[0]["assessment_id"]).to eq(
          "0000-0000-0000-0000-0001",
        )
        expect(pivoted_data[1]["assessment_id"]).to eq(
          "0000-0000-0000-0000-0002",
        )
        expect(pivoted_data[2]["assessment_id"]).to eq(
          "0000-0000-0000-0000-0003",
        )
      end

      it "has a single column for each of the attributes with the relevant values" do
        expect(pivoted_data[0]["construction_age_band"]).to eq(
          "England and Wales: 2007-2011",
        )
        expect(pivoted_data[1]["construction_age_band"]).to eq(
          "England: 1865",
        )
        expect(pivoted_data[2]["construction_age_band"]).to eq(
          "England and Wales: 1971-1987",
        )
      end

      it "can perform simple data aggregations by calculating the sum and average of 'heating_cost_current' when value is an integer" do
        expect(gateway.fetch_sum(attribute_name: "heating_cost_current")).to eq(
          31,
        )
      end

      it "can perform simple data aggregations by calculating the sum and average of 'heating_cost_current' when value is a float" do
        expect(gateway.fetch_sum(attribute_name: "heating_cost_current", value_type: "float").round(2)).to eq(
          32.98,
        )
      end

      it "can perform simple data aggregations by calculating the sum and average of 'heating_cost_current'" do
        expect(
          gateway.fetch_average(attribute_name: "heating_cost_current", value_type: "float").to_f,
        ).to eq(10.99)
      end
    end

    context "when fetching the pivoted data based on the value of an attribute" do
      let(:pivoted_data) do
        gateway.fetch_assessment_attributes(
          attribute_column_array: %w[construction_age_band glazed_type],
          where_clause_hash: { heating_cost_current: "9.45" },
        )
      end

      it "returns only the row for the assessments with that attibute" do
        expect(pivoted_data.count).to eq(1)
        expect(pivoted_data[0]["assessment_id"]).to eq(
          "0000-0000-0000-0000-0003",
        )
      end
    end

    context "when we delete attribute values for a single assessment" do
      before do
        gateway.delete_attributes_by_assessment("0000-0000-0000-0000-0002")
      end

      it "there are no attributes for that assessment" do
        expect(
          ActiveRecord::Base
            .connection
            .exec_query(
              "SELECT * FROM assessment_attribute_values WHERE assessment_id ='0000-0000-0000-0000-0002'",
            )
            .rows
            .count,
        ).to eq(0)
      end

      it "there are attributes for other assessments" do
        expect(
          ActiveRecord::Base
            .connection
            .exec_query(
              "SELECT * FROM assessment_attribute_values WHERE assessment_id ='0000-0000-0000-0000-0001'",
            )
            .rows
            .count,
        ).not_to eq(0)
      end
    end
  end

  context "when updating an existing certificate as opt-out" do
    before do
      gateway.add_attribute_value(
        assessment_id: "0000-0000-0000-0000-0001",
        attribute_name: "opt-out",
        attribute_value: "false",
      )

      gateway.add_attribute_value(\
        assessment_id: "0000-0000-0000-0000-0002",
        attribute_name: "opt-out",
        attribute_value: "false",
      )
      gateway.update_assessment_attribute(assessment_id: "0000-0000-0000-0000-0001", attribute: "opt-out", value: "true")
    end

    it "updates only the relevant certificate to be true" do
      expect(gateway.fetch_attribute_by_assessment(assessment_id: "0000-0000-0000-0000-0001", attribute: "opt-out")).to eq("true")
      expect(gateway.fetch_attribute_by_assessment(assessment_id: "0000-0000-0000-0000-0002", attribute: "opt-out")).to eq("false")
    end
  end

  context "when there is no data present" do
    it "returns false when cheking a certificate has attribute data" do
      expect(gateway.assessment_exists("0000-0000-0000-0000-0001")).to be(false)
    end

    it "returns true when we add certificate data" do
      gateway.add_attribute_value(
        assessment_id: "0000-0000-0000-0000-0001",
        attribute_name: "transaction_type",
        attribute_value: { "description": "marketed sale", "value": "10.0" },
      )
      expect(gateway.assessment_exists("0000-0000-0000-0000-0001")).to be(true)
    end

    context "when deleting an attribute value by name and assessment" do
      before do
        gateway.add_attribute_value(
          assessment_id: "0000-0000-0000-0000-0001",
          attribute_name: "opt-out",
          attribute_value: "true",
        )

        gateway.add_attribute_value(
          assessment_id: "0000-0000-0000-0000-0001",
          attribute_name: "test",
          attribute_value: "test",
        )

        gateway.delete_attribute_value(attribute_name: "opt-out", assessment_id: "0000-0000-0000-0000-0001")
      end

      it "has no records for the opt out attribute" do
        sql = <<-SQL
            SELECT COUNT(*) cnt#{' '}
            FROM assessment_attribute_values aav
            INNER JOIN assessment_attributes aa USING(attribute_id)#{' '}
            WHERE aa.attribute_name = 'opt-out'
        SQL

        expect(ActiveRecord::Base.connection.exec_query(sql, "SQL").first["cnt"]).to eq(0)
      end

      it "still has a record for the test attribute" do
        sql = <<-SQL
            SELECT COUNT(*) cnt#{' '}
            FROM assessment_attribute_values aav
            INNER JOIN assessment_attributes aa USING(attribute_id)#{' '}
            WHERE aa.attribute_name = 'test'
        SQL

        expect(ActiveRecord::Base.connection.exec_query(sql, "SQL").first["cnt"]).to eq(1)
      end
    end
  end

  context "when adding values using #add_attribute_values" do
    before do
      gateway.add_attribute_values(
        AttributeValue.new("construction_age_band", "England and Wales: 2007-2011", nil),
        AttributeValue.new("glazed_type", "test", nil),
        AttributeValue.new("current_energy_efficiency", "50", nil),
        AttributeValue.new("heating_cost_current", "365.98", nil),
        AttributeValue.new("json", json_blob, nil),
        assessment_id: "0000-0000-0000-0000-0001",
      )
    end

    let(:assessment_attribute_values) do
      ActiveRecord::Base.connection.exec_query(
        "SELECT * FROM assessment_attribute_values WHERE assessment_id= '0000-0000-0000-0000-0001'
        ORDER BY attribute_id",
      )
    end

    it "returns a row for every attributes" do
      expect(assessment_attribute_values.rows.length).to eq(5)
    end

    it "row 3 will have a value in the integer column for the current_energy_efficiency" do
      expect(assessment_attribute_values[2]["attribute_value_int"]).to eq(50)
    end

    it "row 4 will have a value in the float column for the heating_cost_current", :aggregate_failures do
      expect(assessment_attribute_values[3]["attribute_value_int"]).to eq 365
      expect(assessment_attribute_values[3]["attribute_value_float"]).to eq 365.98
    end

    it "row 5 will have a json object in the json column" do
      result = JSON.parse(assessment_attribute_values[4]["json"])

      expect(result).to eq(json_blob)
    end

    context "with multiple entries for the same attribute" do
      it "does not raise a BadAttributesWrite error as multiple insert attempts are handled" do
        expect {
          gateway.add_attribute_values(
            AttributeValue.new("glazed_type", "test2", nil),
            assessment_id: "0000-0000-0000-0000-0001",
          )
        }.not_to raise_error
      end
    end

    context "with an entry containing a value that is an integer but larger than PostgreSQL can store using the standard INTEGER type" do
      before do
        gateway.add_attribute_values(AttributeValue.new("location_description", 263_012_400_001_263_012_400_001, nil), assessment_id: "0000-0000-0000-0000-0001")
      end

      it "writes nil for the integer value column" do
        expect(assessment_attribute_values[5]["attribute_value_int"]).to be_nil
      end
    end
  end

  context "when the attributes object is fetched" do
    it "contains all of the currently stored attributes" do
      expect(described_class::Attributes.singleton.attributes.keys).to eq [["test", nil], ["test1", nil]]
    end

    it "can fetch out an ID using brace syntax" do
      expect(described_class::Attributes.singleton[["test", nil]]).to eq 1
    end

    it "can fetch out an ID using #id_for when present" do
      expect(described_class::Attributes.singleton.id_for("test", parent_name: nil)).to eq 1
    end

    it "stores an attribute where it does not currently exist and returns the new ID" do
      expect(described_class::Attributes.singleton.id_for("test2")).to eq 3
    end

    it "fetches the same ID out the second time calling #id_for" do
      described_class::Attributes.singleton.id_for("test2")
      expect(described_class::Attributes.singleton.id_for("test2")).to eq 3
    end
  end

  context "when using the CastValues class" do
    context "when the value is a simple string" do
      it "only keeps the string value, all other methods returning nil", :aggregate_failures do
        cast = described_class::CastValue.new "ND"
        expect(cast.string).to eq "ND"
        expect(cast.int).to be_nil
        expect(cast.float).to be_nil
        expect(cast.json).to be_nil
      end
    end

    context "when the value is an integer-like number string" do
      it "casts the number correctly, and returns nil for the JSON", :aggregate_failures do
        cast = described_class::CastValue.new "42"
        expect(cast.string).to eq "42"
        expect(cast.int).to eq 42
        expect(cast.float).to eq 42.0
        expect(cast.json).to be_nil
      end
    end

    context "when the value is a float-like number string" do
      it "casts the number correctly, losing accuracy with the integer" do
        cast = described_class::CastValue.new "3.14"
        expect(cast.string).to eq "3.14"
        expect(cast.int).to eq 3
        expect(cast.float).to eq 3.14
        expect(cast.json).to be_nil
      end
    end

    context "when the value is a hash" do
      it "makes the hash available through the #json method, with everything else returning nil" do
        cast = described_class::CastValue.new({ code: "NGL" })
        expect(cast.string).to be_nil
        expect(cast.int).to be_nil
        expect(cast.float).to be_nil
        expect(cast.json).to eq({ code: "NGL" })
      end
    end
  end
end

AttributeValue = Struct.new :name, :value, :parent_name

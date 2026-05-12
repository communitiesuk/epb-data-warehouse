shared_context "when saving epcs for fix_list_nodes_serialised_as_objects update" do
  include_context "when saving EPCs"

  def get_node_value(assessment_id, *path)
    sql = <<~SQL
      SELECT document
      FROM assessment_documents
      WHERE assessment_id = $1
    SQL

    bindings = [
      ActiveRecord::Relation::QueryAttribute.new(
        "assessment_id",
        assessment_id,
        ActiveRecord::Type::String.new,
      ),
    ]

    raw = ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)[0]["document"]
    JSON.parse(raw).dig(*path)
  end

  def get_eav_value(assessment_id, attribute_name, *path)
    sql = <<~SQL
      SELECT aav.json
      FROM assessment_attribute_values aav
      JOIN assessment_attributes aa ON aav.attribute_id = aa.attribute_id
      WHERE aav.assessment_id = $1 AND aa.attribute_name = $2
    SQL

    bindings = [
      ActiveRecord::Relation::QueryAttribute.new(
        "assessment_id",
        assessment_id,
        ActiveRecord::Type::String.new,
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "attribute_name",
        attribute_name,
        ActiveRecord::Type::String.new,
      ),
    ]

    row = ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)[0]
    parsed = JSON.parse(row["json"])
    path.empty? ? parsed : parsed.dig(*path)
  end

  def num_incorrect_nodes
    sql = <<~SQL
      SELECT COUNT(*) AS total#{' '}
      FROM assessment_documents
      WHERE jsonb_typeof(document->'sap_energy_source'->'pv_batteries') = 'object'
         OR jsonb_typeof(document->'sap_heating'->'shower_outlets') = 'object'
         OR jsonb_typeof(document->'alternative_improvements') = 'object'
    SQL
    ActiveRecord::Base.connection.exec_query(sql, "SQL")[0]["total"].to_i
  end
end

describe "Fix list nodes serialised as objects Rake" do
  context "when calling the rake task" do
    subject(:task) { get_task("one_off:fix_list_nodes_serialised_as_objects") }

    include_context "when saving epcs for fix_list_nodes_serialised_as_objects update"

    before do
      allow($stdout).to receive(:puts)
      allow($stdout).to receive(:write)
      save_epc(schema: "SAP-Schema-19.1.0", assessment_id: "1111-0000-0000-0000-0001", type: "SAP", stub: ParsedEpcStub.sap_with_broken_list_nodes, registration_date: Date.new(2022, 6, 1))
      save_epc(schema: "RdSAP-Schema-21.0.1", assessment_id: "2222-0000-0000-0000-0002", type: "RdSAP", stub: ParsedEpcStub.rdsap_with_broken_list_nodes, registration_date: Date.new(2022, 6, 1))
      save_epc(schema: "RdSAP-Schema-21.0.1", assessment_id: "3333-0000-0000-0000-0003", type: "RdSAP", registration_date: Date.new(2022, 6, 1))
      save_epc(schema: "SAP-Schema-19.1.0", assessment_id: "4444-0000-0000-0000-0004", type: "SAP", registration_date: Date.new(2012, 6, 1))
    end

    context "when the EPCs have been saved" do
      it "two of the EPCs have broken list nodes" do
        expect(num_incorrect_nodes).to eq(2)
      end

      it "the SAP alternative_improvements node is a hash" do
        sap_19_node = get_node_value("1111-0000-0000-0000-0001", "alternative_improvements")
        expect(sap_19_node).to be_a(Hash)
      end

      it "the RdSAP pv_batteries node is a hash" do
        rdsap_21_node = get_node_value("2222-0000-0000-0000-0002", "sap_energy_source", "pv_batteries")
        expect(rdsap_21_node).to be_a(Hash)
      end

      it "the RdSAP shower_outlets node is a hash" do
        rdsap_21_node = get_node_value("2222-0000-0000-0000-0002", "sap_heating", "shower_outlets")
        expect(rdsap_21_node).to be_a(Hash)
      end

      it "the correctly parsed RdSAP already has pv_batteries as an array" do
        rdsap_21_node = get_node_value("3333-0000-0000-0000-0003", "sap_energy_source", "pv_batteries")
        expect(rdsap_21_node).to be_a(Array)
      end
    end

    context "when the nodes have been updated" do
      let!(:run_task) { task.invoke }

      it "no longer finds any documents with broken list nodes" do
        run_task
        expect(num_incorrect_nodes).to eq(0)
      end

      it "parses SAP alternative_improvements as an array in the document store" do
        run_task
        sap_19_node = get_node_value("1111-0000-0000-0000-0001", "alternative_improvements")
        expect(sap_19_node).to eq([{ "improvement" => { "improvement_type" => "A", "sequence" => 1 } }])
      end

      it "parses RdSAP pv_batteries as an array in the document store" do
        run_task
        rdsap_21_node = get_node_value("2222-0000-0000-0000-0002", "sap_energy_source", "pv_batteries")
        expect(rdsap_21_node).to eq([{ "pv_battery" => { "battery_capacity" => 3.0 } }])
      end

      it "parses RdSAP shower_outlets as an array in the document store" do
        run_task
        rdsap_21_node = get_node_value("2222-0000-0000-0000-0002", "sap_heating", "shower_outlets")
        expect(rdsap_21_node).to eq([{ "shower_outlet" => { "shower_outlet_name" => "Ensuite shower" } }])
      end

      it "parses SAP alternative_improvements EAV value as an array" do
        run_task
        eav_value = get_eav_value("1111-0000-0000-0000-0001", "alternative_improvements")
        expect(eav_value).to eq([{ "improvement" => { "improvement_type" => "A", "sequence" => 1 } }])
      end

      it "parses RdSAP pv_batteries as an array in the EAV store" do
        run_task
        eav_value = get_eav_value("2222-0000-0000-0000-0002", "sap_energy_source", "pv_batteries")
        expect(eav_value).to eq([{ "pv_battery" => { "battery_capacity" => 3.0 } }])
      end

      it "parses RdSAP shower_outlets as an array in the EAV store" do
        run_task
        eav_value = get_eav_value("2222-0000-0000-0000-0002", "sap_heating", "shower_outlets")
        expect(eav_value).to eq([{ "shower_outlet" => { "shower_outlet_name" => "Ensuite shower" } }])
      end

      it "does not double-wrap an already correct array in the document store" do
        run_task
        value = get_node_value("3333-0000-0000-0000-0003", "sap_energy_source", "pv_batteries")
        expect(value).to eq([{ "battery_capacity" => 5 }])
      end
    end

    context "when passing a date range" do
      context "when both END_YEAR and START_YEAR are not set" do
        it "fixes all broken nodes regardless of year" do
          task.invoke
          expect(num_incorrect_nodes).to eq(0)
        end
      end

      context "when only one date is set" do
        context "when only START_YEAR is set" do
          before do
            ENV["START_YEAR"] = "2020"
          end

          after do
            ENV.delete("START_YEAR")
          end

          it "fixes all broken nodes from the START_YEAR onwards" do
            task.invoke
            expect(num_incorrect_nodes).to eq(0)
          end
        end

        context "when only END_YEAR is set" do
          before do
            ENV["END_YEAR"] = "2021"
          end

          after do
            ENV.delete("END_YEAR")
          end

          it "fixes all broken nodes from 2012 up to the END_YEAR" do
            task.invoke
            expect(num_incorrect_nodes).to eq(2)
          end
        end
      end

      context "when START_YEAR is greater than END_YEAR" do
        before do
          ENV["START_YEAR"] = "2025"
          ENV["END_YEAR"] = "2020"
        end

        after do
          ENV.delete("START_YEAR")
          ENV.delete("END_YEAR")
        end

        it "raises an ArgumentError" do
          expect { task.invoke }.to raise_error(ArgumentError, /START_YEAR.*must be less than or equal to END_YEAR/)
        end
      end

      context "when END_YEAR is set to a year before the EPCs" do
        before do
          ENV["END_YEAR"] = "2021"
        end

        after do
          ENV.delete("END_YEAR")
        end

        it "does not fix any broken nodes" do
          task.invoke
          expect(num_incorrect_nodes).to eq(2)
        end
      end

      context "when START_YEAR and END_YEAR are set to the EPCs' year" do
        before do
          ENV["START_YEAR"] = "2022"
          ENV["END_YEAR"] = "2022"
        end

        after do
          ENV.delete("START_YEAR")
          ENV.delete("END_YEAR")
        end

        it "fixes the broken nodes within the year range" do
          task.invoke
          expect(num_incorrect_nodes).to eq(0)
        end
      end
    end
  end
end

require_relative "../shared_context/shared_lodgement"

describe "Backfill commercial_reports table rake" do
  before do
    ActiveRecord::Base.connection.exec_query("TRUNCATE TABLE commercial_reports;")
  end

  context "when calling the rake task" do
    subject(:task) { get_task("one_off:backfill_commercial_reports") }

    include_context "when lodging XML"

    let(:result) do
      ActiveRecord::Base.connection.exec_query(
        "SELECT * FROM commercial_reports",
      )
    end

    before(:all) do
      add_countries

      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0001", schema_type: "CEPC-8.0.0", type_of_assessment: "CEPC", type: "cepc", add_to_assessment_search: true, different_fields: {
        "country_id": 1, "related_rrn" => "0000-0000-0000-0000-0011"
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0002", schema_type: "CEPC-7.0", type_of_assessment: "CEPC", type: "cepc-rr", add_to_assessment_search: true, different_fields: {
        "related_rrn" => "0000-0000-0000-0000-0022", "country_id": 1
      })
      add_assessment_eav(assessment_id: "0000-0000-0000-0000-0003", schema_type: "CEPC-7.0", type_of_assessment: "DEC", type: "dec-rr", add_to_assessment_search: true, different_fields: {
        "related_rrn" => "0000-0000-0000-0000-0033", "country_id": 1
      })
    end

    context "when certificates have been saved" do
      it "saves DECs and CEPCs into commercial_reports table" do
        task.invoke
        expect(result.length).to eq(3)
      end

      it "inserting a duplicate assessment does not raise an error" do
        task.invoke
        task.reenable
        expect { task.invoke }.not_to raise_error
        expect(result.length).to eq(3)
      end

      context "when there are domestic assessments" do
        before do
          add_assessment_eav(assessment_id: "0000-0000-0000-0000-0004", schema_type: "SAP-Schema-19.0.0", type_of_assessment: "SAP", add_to_assessment_search: true, different_fields: {
            "country_id": 2,
          })
        end

        it "doesn't insert invalid assessment types" do
          task.invoke
          expect(result.length).to eq(3)
        end
      end

      context "when there are valid assessments with no related_rrn" do
        before do
          add_assessment_eav(assessment_id: "0000-0000-0000-0000-0005", schema_type: "CEPC-8.0.0", type_of_assessment: "DEC", type: "dec-rr", add_to_assessment_search: true, different_fields: {
            "country_id": 2, "related_rrn" => nil
          })
        end

        it "doesn't insert assessments without related_rrn" do
          task.invoke
          expect(result.length).to eq(3)
        end
      end
    end
  end
end

describe "Update address in assessment_search with non-alphanumeric values data rake" do
  before do
    ActiveRecord::Base.connection.execute("TRUNCATE assessment_search")
  end

  context "when calling the rake task" do
    subject(:task) { get_task("one_off:update_address_assessment_search") }

    let(:results) do
      ActiveRecord::Base.connection.execute("SELECT assessment_id, address FROM assessment_search ORDER BY assessment_id").map { |row| row }
    end

    context "when the existing uprn values are null" do
      before do
        sql = <<-SQL
        INSERT INTO assessment_search(assessment_id, address, registration_date)#{' '}
        VALUES ('0000-0000-0000-0000-0001', '1, main street south flower estate new town!', current_date),#{' '}
               ('0000-0000-0000-0000-0002', '2, st. James''s park street flower estate new town?', current_date),#{' '}
               ('0000-0000-0000-0000-0003', '3, main street (flower) estate new town!', current_date)
        SQL

        ActiveRecord::Base.connection.execute(sql)
      end

      let(:expected) do
        [
          { "assessment_id" => "0000-0000-0000-0000-0001", "address" => "1 main street south flower estate new town" },
          { "assessment_id" => "0000-0000-0000-0000-0002", "address" => "2 st Jamess park street flower estate new town" },
          { "assessment_id" => "0000-0000-0000-0000-0003", "address" => "3 main street flower estate new town" },
        ]
      end

      it "updates the relevant urpns with values from the assessment_address_id" do
        task.invoke
        expect(results).to eq(expected)
      end
    end
  end
end

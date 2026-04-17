describe "Update address in assessment_search to remove commas and replace them with a white space" do
  before do
    ActiveRecord::Base.connection.execute("TRUNCATE assessment_search")
  end

  context "when calling the rake task" do
    subject(:task) { get_task("one_off:update_address_assessment_search") }

    let(:results) do
      ActiveRecord::Base.connection.execute("SELECT assessment_id, address FROM assessment_search ORDER BY assessment_id").map { |row| row }
    end

    context "when the address contains commas and additional whitespaces" do
      before do
        sql = <<-SQL
        INSERT INTO assessment_search(assessment_id, address, registration_date)#{' '}
        VALUES ('0000-0000-0000-0000-0001', '1a,-1b, main street south flower estate new town!', current_date),#{' '}
               ('0000-0000-0000-0000-0002', '2,    3 st. james''s park street flower estate new town?', current_date),#{' '}
               ('0000-0000-0000-0000-0003', '3,4, 5 main street (flower) estate stockton-on-tees!', current_date)
        SQL

        ActiveRecord::Base.connection.execute(sql)
      end

      let(:expected) do
        [
          { "assessment_id" => "0000-0000-0000-0000-0001", "address" => "1a -1b main street south flower estate new town!" },
          { "assessment_id" => "0000-0000-0000-0000-0002", "address" => "2 3 st. james's park street flower estate new town?" },
          { "assessment_id" => "0000-0000-0000-0000-0003", "address" => "3 4 5 main street (flower) estate stockton-on-tees!" },
        ]
      end

      it "replaces commas with a space and squashes the whitespaces" do
        task.invoke
        expect(results).to eq(expected)
      end
    end
  end
end

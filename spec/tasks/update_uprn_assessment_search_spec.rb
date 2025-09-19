describe "Update uprn in assessment_search with assessment_address_id data rake" do
  before do
    ActiveRecord::Base.connection.execute("TRUNCATE assessment_search")
  end

  context "when calling the rake task" do
    subject(:task) { get_task("one_off:update_uprn_assessment_search") }

    let(:results) do
      ActiveRecord::Base.connection.execute("SELECT assessment_id, uprn FROM assessment_search ORDER BY assessment_id").map { |row| row }
    end

    context "when the existing uprn values are null" do
      before do
        sql = <<-SQL
        INSERT INTO assessment_search(assessment_id, assessment_address_id, registration_date, uprn)#{' '}
        VALUES ('0000-0000-0000-0000-0001', 'UPRN-000011112222', current_date, null),#{' '}
               ('0000-0000-0000-0000-0002', 'UPRN-000011112223', current_date, null )
        SQL

        ActiveRecord::Base.connection.execute(sql)
      end

      let(:expected) do
        [
          { "assessment_id" => "0000-0000-0000-0000-0001", "uprn" => 11_112_222 },
          { "assessment_id" => "0000-0000-0000-0000-0002", "uprn" => 11_112_223 },

        ]
      end

      it "updates the relevant urpns with values from the assessment_address_id" do
        task.invoke
        expect(results).to eq(expected)
      end
    end

    context "when the existing uprn values are not null" do
      before do
        sql = <<-SQL
        INSERT INTO assessment_search(assessment_id, assessment_address_id, registration_date, uprn)#{' '}
        VALUES ('0000-0000-0000-0000-0003', 'UPRN-000011112223', current_date, 123355 )
        SQL

        ActiveRecord::Base.connection.execute(sql)
      end

      let(:expected) do
        [
          { "assessment_id" => "0000-0000-0000-0000-0003", "uprn" => 123_355 },
        ]
      end

      it "the uprn value remains unchanged" do
        task.invoke
        expect(results).to eq(expected)
      end
    end

    context "when the assessment_address_id has an RRN values" do
      before do
        sql = <<-SQL
        INSERT INTO assessment_search(assessment_id, assessment_address_id, registration_date, uprn)#{' '}
        VALUES ('0000-0000-0000-0000-0001', 'RRN-0000-0000-0000-0000-0001', current_date, null)
        SQL

        ActiveRecord::Base.connection.execute(sql)
      end

      it "the urpn will be not be updated" do
        task.invoke
        expect(results.first["urpn"]).to be_nil
      end
    end
  end
end

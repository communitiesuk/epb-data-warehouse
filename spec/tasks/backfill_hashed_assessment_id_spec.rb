describe "Adding or updating hashed assessment id node rake" do
  context "when calling the rake task" do
    subject(:task) { get_task("one_off:add_hashed_assessment_id_node") }

    before do
      # allow($stdout).to receive(:puts)
      # allow($stdout).to receive(:write)
      # save_epc(schema: "SAP-Schema-18.0.0", assessment_id: "0000-0000-0000-0000-0000", assessment_type: "SAP", sample_type: "epc", hashed_assessment_id: "6ebf834b9a43884e1436ec234ddf3cd04c6e55f90a3e94a42cc69c252b9ae7e2")
      # save_epc(schema: "SAP-Schema-17.0", assessment_id: "5555-5555-5555-5555-5555", type: "SAP", sample_type: "epc")
      # save_epc(schema: "RdSAP-Schema-19.0", assessment_id: "0000-6666-4444-3333-2222", type: "RdSAP", sample_type: "epc")
      save_epc(schema: "CEPC-8.0.0", assessment_id: "0000-7777-4444-3333-2222", assessment_type: "CEPC", sample_type: "cepc", hashed_assessment_id: "6ebf834b9a43884e1436ec234ddf3cd04c6e55f90a3e94a42cc69c252b9ae7e2")
      # save_epc(schema: "CEPC-8.0.0", assessment_id: "0000-8888-4444-3333-2222", type: "DEC", sample_type: "dec+rr")
      # save_epc(schema: "CEPC-8.0.0", assessment_id: "0000-9999-4444-3333-2222", type: "AC-CERT", sample_type: "ac-cert+rr")
    end

    context "when certificates have been saved" do

      it "the value of the nodes for the SAP 18 has a hashed assessment id ", aggregate_failure: true do
        sap_18_node = get_node_values("0000-7777-4444-3333-2222")
        pp "THE node values"
        pp sap_18_node
        expect(sap_18_node).to be_a Hash
      end

    end

    # context "when the nodes have been added or updated" do
    #   let!(:run_task) { task.invoke }
    #
    #   it "no longer find any document who have hash in the node lzc_energy_sources" do
    #     run_task
    #     expect(num_incorrect_nodes).to eq(0)
    #   end
    #
    #   it "the value of the nodes are now arrays " do
    #     run_task
    #     expect(JSON.parse(get_node_value("0000-0000-0000-0000-0000"))).to eq [9]
    #     expect(JSON.parse(get_node_value("5555-5555-5555-5555-5555"))).to eq [10]
    #   end
    #
    #   it "the value of the nodes in the EAV are now arrays " do
    #     run_task
    #     expect(JSON.parse(get_node_value_from_eav("0000-0000-0000-0000-0000"))).to eq [9]
    #     expect(JSON.parse(get_node_value_from_eav("5555-5555-5555-5555-5555"))).to eq [10]
    #   end
    # end
  end
end

def save_epc(schema:, assessment_id:, assessment_type:, sample_type:, hashed_assessment_id: nil)

  sample = Samples.xml(schema, sample_type)
  pp sample
  pp "%%%%"
  use_case = UseCase::ParseXmlCertificate.new
  parsed_epc = use_case.execute(xml: sample, schema_type: schema, assessment_id: assessment_id)
  pp parsed_epc
  pp "***********************"
  unless hashed_assessment_id == nil
    parsed_epc["hashed_assessment_id"] = hashed_assessment_id
  end
  parsed_epc["assessment_type"] = assessment_type
  parsed_epc["schema_type"] = schema
  pp parsed_epc
  import = UseCase::ImportCertificateData.new(assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, documents_gateway: Gateway::DocumentsGateway.new)
  pp "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
  pp parsed_epc
  import.execute(assessment_id:, certificate_data: parsed_epc)

end

def get_node_value(assessment_id)
  sql = <<-SQL
       SELECT document ->> 'hashed_assessment_id' as hashed_assessment_id
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

  ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)[0]["hashed_assessment_id"]
end

def get_node_values(assessment_id)
  sql = <<-SQL
       SELECT *
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

  ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings).rows
end

def num_incorrect_nodes
  sql = <<-SQL
         select COUNT(*) as total
         FROM assessment_documents
        WHERE
         nullif((document ->> 'lzc_energy_sources')::json ->> 'lzc_energy_source', '') != ''
  SQL

  ActiveRecord::Base.connection.exec_query(sql, "SQL")[0]["total"].to_i
end

def get_node_value_from_eav(assessment_id)
  sql = <<-SQL
       SELECT json
        FROM assessment_attribute_values
        WHERE assessment_id = $1 And attribute_id = (SELECT attribute_id FROM assessment_attributes WHERE attribute_name = 'lzc_energy_sources' LIMIT 1)
  SQL

  bindings = [
    ActiveRecord::Relation::QueryAttribute.new(
      "assessment_id",
      assessment_id,
      ActiveRecord::Type::String.new,
      ),
  ]

  ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)[0]["json"]
end

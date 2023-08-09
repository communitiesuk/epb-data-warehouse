shared_context "when saving epcs for fix_lzc_energy_node update" do
  def save_epc(schema:, assessment_id:, type:, stub: nil)
    if stub.nil?
      sample = Samples.xml(schema)
      use_case = UseCase::ParseXmlCertificate.new
      parsed_epc = use_case.execute(xml: sample, schema_type: schema, assessment_id:)
    else
      parsed_epc = stub
    end
    parsed_epc["assessment_type"] = type
    parsed_epc["schema_type"] = schema
    import = UseCase::ImportCertificateData.new(assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, documents_gateway: Gateway::DocumentsGateway.new)
    import.execute(assessment_id:, certificate_data: parsed_epc)
  end

  def get_node_value(assessment_id)
    sql = <<-SQL
       SELECT document ->> 'lzc_energy_sources' as lsz_node
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

    ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)[0]["lsz_node"]
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
end

describe "Fix node Rake" do
  context "when calling the rake task" do
    subject(:task) { get_task("one_off:fix_lzc_energy_node") }

    include_context "when saving epcs for fix_lzc_energy_node update"

    before do
      allow($stdout).to receive(:puts)
      allow($stdout).to receive(:write)
      save_epc(schema: "SAP-Schema-18.0.0", assessment_id: "0000-0000-0000-0000-0000", type: "SAP", stub: ParsedEpcStub.sap18_incorret_lzc)
      save_epc(schema: "SAP-Schema-17.0", assessment_id: "5555-5555-5555-5555-5555", type: "SAP", stub: ParsedEpcStub.sap17_0_incorret_lzc)
      save_epc(schema: "RdSAP-Schema-19.0", assessment_id: "0000-6666-4444-3333-2222", type: "RdSAP")
    end

    context "when domestic EPCs have been saved" do
      it "two of the epcs have incorrect nodes" do
        expect(num_incorrect_nodes).to eq(2)
      end

      it "the value of the nodes for the SAP 17 is a hash ", aggregate_failure: true do
        sap_17_node = JSON.parse(get_node_value("5555-5555-5555-5555-5555"))
        expect(sap_17_node).to be_a Hash
      end

      it "the value of the node for the SAP 18 is a hash " do
        sap_18_node = JSON.parse(get_node_value("0000-0000-0000-0000-0000"))
        expect(sap_18_node).to be_a Hash
      end

      it "the value of the node for the SAP 19 is the correct array " do
        sap_19_node = JSON.parse(get_node_value("0000-6666-4444-3333-2222"))
        expect(sap_19_node).to be_a Array
      end
    end

    context "when the nodes have been updated " do
      let!(:run_task) { task.invoke }

      it "no longer find any document who have hash in the node lzc_energy_sources" do
        run_task
        expect(num_incorrect_nodes).to eq(0)
      end

      it "the value of the nodes are now arrays " do
        run_task
        expect(JSON.parse(get_node_value("0000-0000-0000-0000-0000"))).to eq [9]
        expect(JSON.parse(get_node_value("5555-5555-5555-5555-5555"))).to eq [10]
      end

      it "the value of the nodes in the EAV are now arrays " do
        run_task
        expect(JSON.parse(get_node_value_from_eav("0000-0000-0000-0000-0000"))).to eq [9]
        expect(JSON.parse(get_node_value_from_eav("5555-5555-5555-5555-5555"))).to eq [10]
      end
    end
  end
end

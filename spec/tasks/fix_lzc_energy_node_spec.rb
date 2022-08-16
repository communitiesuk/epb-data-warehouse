describe "Fix node Rake" do
  context "when calling the rake task" do
    subject(:task) { get_task("fix_lzc_energy_node") }
    before do
      # allow($stdout).to receive(:puts)
      # allow($stdout).to receive(:write)
      save_epc(schema: "SAP-Schema-18.0.0", assessment_id: "0000-0000-0000-0000-0000", type: "SAP")
      save_epc(schema: "SAP-Schema-NI-17.3", assessment_id: "2222-0000-3333-5555-4444", type: "SAP")
      save_epc(schema: "SAP-Schema-17.0", assessment_id: "1111-2222-3333-4444-5555", type: "SAP")
      save_epc(schema: "RdSAP-Schema-19.0", assessment_id: "0000-6666-4444-3333-2222", type: "RdSAP")
    end

    context "when domestic EPCs been saved" do
      it "two of the epcs have incorrect nodes" do
        expect(num_incorrect_nodes).to eq(2)
      end

      it "the value of the nodes for the SAP 17 is a hash " do
        sap_ni_17_node = JSON.parse(get_node_value("2222-0000-3333-5555-4444"))
        sap_17_node = JSON.parse(get_node_value("1111-2222-3333-4444-5555"))
        expect(sap_ni_17_node).to be_a Hash
        expect(sap_17_node).to be_a Hash
      end

      it "the value of the node for the SAP 18 is a hash " do
        node = JSON.parse(get_node_value("0000-0000-0000-0000-0000"))
        expect(node).to be_a Array
      end
    end

    context "when the rake has run to update the incorrect nodes" do
      before do
        task.invoke
      end

      it "no longer find any document who have hash in the node lzc_energy_sources" do
        expect(num_incorrect_nodes).to eq(0)
      end

      it "the value of the node for the SAP is now and array " do
        node = JSON.parse(get_node_value("2222-0000-3333-5555-4444"))
        expect(node).to be_a Array
      end

      it "the value of the nodes are now arrays " do
        sap_ni_17_node = JSON.parse(get_node_value("2222-0000-3333-5555-4444"))
        sap_17_node = JSON.parse(get_node_value("1111-2222-3333-4444-5555"))
        expect(sap_ni_17_node).to be_a Array
        expect(sap_ni_17_node[0]).to eq 4
        expect(sap_17_node).to be_a Array
        expect(sap_17_node[0]).to eq 10
      end

      it "the value of the nodes in the EAV are now arrays " do
        sap_ni_17_node = JSON.parse(get_node_value_from_eav("2222-0000-3333-5555-4444"))
        sap_17_node = JSON.parse(get_node_value_from_eav("1111-2222-3333-4444-5555"))
        expect(sap_ni_17_node).to be_a Array
        expect(sap_ni_17_node[0]).to eq 4
        expect(sap_17_node).to be_a Array
        expect(sap_17_node[0]).to eq 10
      end


    end
    # it "saves 3 epcs that have the incorrect node" do
    #
    # end
  end
end

def save_epc(schema:, assessment_id:, type:)
  sample = Samples.xml(schema)
  use_case = UseCase::ParseXmlCertificate.new
  json = use_case.execute(xml: sample, schema_type: schema, assessment_id: assessment_id)
  json["assessment_type"] = schema
  json["schema_type"] = schema
  import = UseCase::ImportCertificateData.new(assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, documents_gateway: Gateway::DocumentsGateway.new)
  json["assessment_type"] = type
  import.execute(assessment_id: assessment_id, certificate_data: json)
end

def get_node_value(assessment_id)
  sql = <<-SQL
       SELECT document ->> 'lzc_energy_sources' as lsz_node
       FROM assessment_documents#{' '}
       WHERE assessment_id = $1
  SQL

  bindings = [
    ActiveRecord::Relation::QueryAttribute.new(
      "assessment_id",
      assessment_id,
      ActiveRecord::Type::String.new,
    )
  ]

  ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)[0]["lsz_node"]
end

def num_incorrect_nodes
  sql = <<-SQL
         select COUNT(*) as total
         FROM assessment_documents#{' '}
         WHERE document ->> 'assessment_type' IN ('SAP', 'RdSAP')
        AND nullif((document ->> 'lzc_energy_sources')::json ->> 'lzc_energy_source', '') != ''
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
      )
  ]

  ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)[0]["json"]
end
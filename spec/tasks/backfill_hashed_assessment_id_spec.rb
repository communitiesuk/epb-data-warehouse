describe "Adding or updating hashed assessment id node rake" do
  context "when calling the rake task" do
    subject(:task) { get_task("one_off:add_hashed_assessment_id_node") }

    before do
      save_new_epc(schema: "SAP-Schema-18.0.0", assessment_id: "0000-0000-0000-0000-0000", assessment_type: "SAP", sample_type: "epc", hashed_assessment_id: "7777734b9a43884e1436ec234ddf3cd04c6e55f90a3e94a42cc69c252b9ae7e2")
      save_new_epc(schema: "SAP-Schema-17.0", assessment_id: "5555-5555-5555-5555-5555", assessment_type: "SAP", sample_type: "epc")
      save_new_epc(schema: "RdSAP-Schema-19.0", assessment_id: "0000-6666-4444-3333-2222", assessment_type: "RdSAP", sample_type: "epc")
    end

    context "when certificates have been saved" do
      it "the value of the nodes for the SAP 18 has a hashed assessment id", :aggregate_failure do
        sap_18_hashed_assessment_id_json = get_hashed_assessment_id_from_json("0000-0000-0000-0000-0000")
        sap_18_hashed_assessment_id_eav = get_hashed_assessment_id_from_eav("0000-0000-0000-0000-0000")

        expect(sap_18_hashed_assessment_id_json).to eq("7777734b9a43884e1436ec234ddf3cd04c6e55f90a3e94a42cc69c252b9ae7e2")
        expect(sap_18_hashed_assessment_id_eav).to eq("7777734b9a43884e1436ec234ddf3cd04c6e55f90a3e94a42cc69c252b9ae7e2")
      end

      it "the value of the nodes for the SAP 17 has no hashed assessment id", :aggregate_failure do
        sap_17_hashed_assessment_id_json = get_hashed_assessment_id_from_json("5555-5555-5555-5555-5555")
        expect(sap_17_hashed_assessment_id_json).to be_nil
      end
    end

    context "when the nodes have been added or updated" do
      let!(:run_task) { task.invoke }

      it "no longer finds any incorrect hashed_assessment_ids" do
        run_task
        sap_18_hashed_assessment_id_eav = get_hashed_assessment_id_from_eav("0000-0000-0000-0000-0000")
        sap_18_hashed_assessment_id_json = get_hashed_assessment_id_from_json("0000-0000-0000-0000-0000")

        expect(sap_18_hashed_assessment_id_eav).to eq("4af9d2c31cf53e72ef6f59d3f59a1bfc500ebc2b1027bc5ca47361435d988e1a")
        expect(sap_18_hashed_assessment_id_json).to eq("4af9d2c31cf53e72ef6f59d3f59a1bfc500ebc2b1027bc5ca47361435d988e1a")
      end

      it "previously missing hashed assessment ids are added to a SAP" do
        run_task
        sap_17_hashed_assessment_id_eav = get_hashed_assessment_id_from_eav("5555-5555-5555-5555-5555")
        sap_17_hashed_assessment_id_json = get_hashed_assessment_id_from_json("5555-5555-5555-5555-5555")

        expect(sap_17_hashed_assessment_id_eav).to eq("101d5774880620c7e68ece9d5f7a39e43c7f926ef9110bdd802218a1a046ebea")
        expect(sap_17_hashed_assessment_id_json).to eq("101d5774880620c7e68ece9d5f7a39e43c7f926ef9110bdd802218a1a046ebea")
      end

      it "previously missing hashed assessment ids are added to an RdSAP" do
        run_task
        rdsap_19_hashed_assessment_id_eav = get_hashed_assessment_id_from_eav("0000-6666-4444-3333-2222")
        rdsap_19_hashed_assessment_id_json = get_hashed_assessment_id_from_json("0000-6666-4444-3333-2222")

        expect(rdsap_19_hashed_assessment_id_eav).to eq("6d42518137491ecfef3053efa480079d4f1fdaf377d3be6587d0ecc713365619")
        expect(rdsap_19_hashed_assessment_id_json).to eq("6d42518137491ecfef3053efa480079d4f1fdaf377d3be6587d0ecc713365619")
      end
    end
  end
end

def save_new_epc(schema:, assessment_id:, assessment_type:, sample_type:, hashed_assessment_id: nil)
  sample = Samples.xml(schema, sample_type)
  use_case = UseCase::ParseXmlCertificate.new
  parsed_epc = use_case.execute(xml: sample, schema_type: schema, assessment_id:)
  unless hashed_assessment_id.nil?
    parsed_epc["hashed_assessment_id"] = hashed_assessment_id
  end
  parsed_epc["assessment_type"] = assessment_type
  parsed_epc["schema_type"] = schema
  import = UseCase::ImportCertificateData.new(assessment_attribute_gateway: Gateway::AssessmentAttributesGateway.new, documents_gateway: Gateway::DocumentsGateway.new, assessment_search_gateway: Gateway::AssessmentSearchGateway.new, assessments_address_id_gateway: Gateway::AssessmentsAddressIdGateway.new, commercial_reports_gateway: Gateway::CommercialReportsGateway.new)
  import.execute(assessment_id:, certificate_data: parsed_epc)
end

def get_hashed_assessment_id_from_json(assessment_id)
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

def get_hashed_assessment_id_from_eav(assessment_id)
  sql = <<-SQL
       SELECT attribute_value
        FROM assessment_attribute_values
        WHERE assessment_id = $1 AND attribute_id = (SELECT attribute_id FROM assessment_attributes WHERE attribute_name = 'hashed_assessment_id' LIMIT 1)
  SQL

  bindings = [
    ActiveRecord::Relation::QueryAttribute.new(
      "assessment_id",
      assessment_id,
      ActiveRecord::Type::String.new,
    ),
  ]

  ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)[0]["attribute_value"]
end

class CreateVwRedactedAssessmentDocuments < ActiveRecord::Migration[7.0]
  def self.up
    execute "
    CREATE VIEW vw_redacted_assessment_documents AS
    SELECT
      assessment_id AS certificate_number,
      document - 'scheme_assessor_id' - 'equipment_owner' - 'equipment_operator' - 'owner' - 'occupier' AS document,
      warehouse_created_at,
      updated_at,
      document ->> 'assessment_type' AS assessment_type
    FROM assessment_documents ad
    WHERE EXISTS (SELECT 1 FROM assessment_search ase WHERE ase.assessment_id = ad.assessment_id)
    "
  end

  def self.down; end
end

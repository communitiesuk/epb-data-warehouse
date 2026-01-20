class DeleteSap15FromAssessmentSearchTable < ActiveRecord::Migration[7.0]
  def self.up
    execute "DELETE FROM assessment_search
              WHERE assessment_id IN (
                  SELECT s.assessment_id
                  FROM assessment_search s
                  JOIN assessment_documents d ON s.assessment_id = d.assessment_id
                  WHERE s.created_at BETWEEN '2012-01-01' AND '2013-01-01'
                    AND s.assessment_type IN ('RdSAP', 'SAP')
                    AND d.document ->> 'schema_type' = 'SAP-Schema-15.0'
              );
              "
  end

  def self.down; end
end

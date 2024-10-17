class AlterIndexCreatedAtAssessmentDocuments < ActiveRecord::Migration[7.0]
  def self.up
    execute %(DROP INDEX IF EXISTS "index_document_created_At")
    execute "CREATE INDEX IF NOT EXISTS index_document_created_at ON public.assessment_documents USING btree (((document ->> 'created_at'::text)))"
  end


end

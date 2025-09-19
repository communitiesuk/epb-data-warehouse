class AlterFnExportJsonDocumentRelatedRrn < ActiveRecord::Migration[7.0]
  def self.up
    execute "CREATE OR REPLACE FUNCTION fn_export_json_document(document jsonb) RETURNS jsonb
    language plpgsql
    as
    $$
      DECLARE
       data jsonb;
       address_id text;
       uprn bigint;

    BEGIN

      address_id := REPLACE((document ->> 'assessment_address_id')::text,   'UPRN-', '');

      data := document
        - 'scheme_assessor_id'::text
        - 'equipment_owner'::text
        - 'equipment_operator'::text
        - 'owner'::text
        - 'occupier'::text
        - 'assessment_address_id'::text
        - 'calculation_software_name'::text
        - 'opt_out'::text
        - 'hashed_assessment_id'::text
        - 'cancelled_at'::text
        - 'related_rrn'::text;

      IF document ? 'related_rrn' THEN
          data := data || jsonb_build_object('related_certificate_number', document -> 'related_rrn');
      END IF;

      IF starts_with(address_id, 'RRN') THEN
          address_id := '';
          data := jsonb_set(data, '{uprn}', 'null'::jsonb, true);
      ELSE
          data := jsonb_set(data, '{uprn}', to_jsonb((address_id)::bigint), true);
      END IF;

      return data;
    END
    $$;"
  end

  def self.down; end
end

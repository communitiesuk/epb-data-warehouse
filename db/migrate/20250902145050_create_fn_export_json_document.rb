class CreateFnExportJsonDocument < ActiveRecord::Migration[7.0]
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
  data := document - 'scheme_assessor_id'::text - 'equipment_owner'::text - 'equipment_operator'::text - 'owner'::text -
             'occupier'::text - 'uprn'::text - 'assessment_address_id'::text;

  IF starts_with(address_id, 'RRN') THEN
      address_id := '';
      SELECT jsonb_insert(data, '{building_reference_number}','null'::jsonb) into data;
  ELSE
  uprn := address_id::bigint;
  SELECT jsonb_insert(data, '{building_reference_number}', uprn::text::jsonb) into data;
  END IF;
  return data;
END
$$;"
  end

  def self.down; end
end

class AlterFnExportJsonDocumentEnergyBand < ActiveRecord::Migration[7.0]
  def self.up
    execute "CREATE OR REPLACE FUNCTION fn_export_json_document(document jsonb) RETURNS jsonb
    language plpgsql
    as
    $$
      DECLARE
       data jsonb;
       address_id text;
       uprn bigint;
       energy_band varchar(2);
       assessment_type varchar(7);

    BEGIN

       address_id := REPLACE((document ->> 'assessment_address_id')::text,   'UPRN-', '');
       assessment_type  :=  (document->> 'assessment_type')::varchar;

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

      IF assessment_type = 'CEPC' THEN
          energy_band := energy_band_calculator((document ->> 'asset_rating')::int,  assessment_type);
       ELSIF assessment_type = 'DEC' THEN
          energy_band := energy_band_calculator((document -> 'this_assessment' ->> 'energy_rating')::int,  assessment_type);
       ELSIF assessment_type LIKE '%RR%' THEN
          energy_band := null;
      ELSE
           energy_band := energy_band_calculator((document ->> 'energy_rating_current')::int,  assessment_type);
      END IF;

      if energy_band IS NOT NULL THEN
        data := jsonb_set(data, '{current_energy_efficiency_band}', to_jsonb((energy_band)::varchar), true);
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

  def self.down
    execute "DROP VIEW fn_export_json_document"
  end
end

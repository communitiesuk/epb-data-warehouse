class FnExportJsonDocumentFilterOutMatchedUprn < ActiveRecord::Migration[8.1]
  def self.up
    execute "CREATE OR REPLACE FUNCTION fn_export_json_document(document jsonb, matched_uprn bigint) RETURNS jsonb
    language plpgsql
    as
    $$
      DECLARE
       data jsonb;
       address_id text;
       uprn varchar(20);
       uprn_source varchar(20);
       energy_band varchar(2);
       assessment_type varchar(7);
       potential_energy_band varchar(2);

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
        - 'related_rrn'::text
        - 'matched_uprn'::text;

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
           potential_energy_band := energy_band_calculator((document ->> 'energy_rating_potential')::int,  assessment_type);
      END IF;

      if energy_band IS NOT NULL THEN
        data := jsonb_set(data, '{current_energy_efficiency_band}', to_jsonb((energy_band)::varchar), true);
       END IF;

      if potential_energy_band IS NOT NULL THEN
        data := jsonb_set(data, '{potential_energy_efficiency_band}', to_jsonb((potential_energy_band)::varchar), true);
       END IF;

      IF NOT starts_with(address_id, 'RRN') THEN
          uprn := address_id;
          uprn_source := 'Energy Assessor';
      ELSIF matched_uprn IS NOT NULL THEN
          uprn := matched_uprn::text;
          uprn_source := 'Address Matched';
      ELSE
          uprn := NULL;
          uprn_source := '';
      END IF;


      IF uprn IS NULL THEN
          address_id := '';
          data := jsonb_set(data, '{uprn}', 'null'::jsonb, true);
      ELSE
          data := jsonb_set(data, '{uprn}', to_jsonb((uprn)::bigint), true);
      END IF;

      data := jsonb_set(data, '{uprn_source}', to_jsonb(uprn_source), true);

      return data;
    END
    $$;"
  end

  def self.down; end
end

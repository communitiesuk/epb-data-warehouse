class AlterDomesticSearchMv < ActiveRecord::Migration[7.0]
  def self.up
    execute "DROP MATERIALIZED VIEW IF EXISTS mvw_domestic_search "
    execute "CREATE MATERIALIZED VIEW mvw_domestic_search
AS
SELECT
    ad.assessment_id as rrn,
    document ->> 'address_line_1' as ADDRESS1,
    document ->> 'address_line_2' as ADDRESS2,
    document ->> 'address_line_3' as ADDRESS3,
    document ->> 'postcode' as POSTCODE,
    document ->> 'total_floor_area' as TOTAL_FLOOR_AREA,
    document->>'energy_rating_current' as CURRENT_ENERGY_RATING,
    document->>'registration_date' as LODGEMENT_DATE,
    os_la.name as LOCAL_AUTHORITY_LABEL,
    os_p.name as CONSTITUENCY_LABEL,
    get_lookup_value('transaction_type', document ->> 'transaction_type', document ->> 'assessment_type', document->> 'schema_type' ) as TRANSACTION_TYPE,
    get_lookup_value('property_type', document ->> 'property_type', document ->> 'assessment_type', document->> 'schema_type' ) as PROPERTY_TYPE,


    LOWER(CONCAT_WS(' ', (document ->> 'address_line_1')::varchar,
                    (document ->> 'address_line_2')::varchar,
                    (document ->> 'address_line_3')::varchar,
                    (document ->> 'post_town')::varchar)) as full_address
FROM assessment_documents ad
join assessments_country_ids aci on ad.assessment_id = aci.assessment_id
join countries co on aci.country_id = co.country_id
left JOIN ons_postcode_directory ons on document ->> 'postcode' = ons.postcode
left join ons_postcode_directory_names os_la on ons.local_authority_code = os_la.area_code
left join ons_postcode_directory_names os_p on ons.westminster_parliamentary_constituency_code = os_p.area_code
WHERE document ->> 'assessment_type' IN ('RdSAP', 'SAP')
  AND co.country_code IN ('EAW', 'ENG', 'WLS')
ORDER BY rrn
WITH NO DATA;
"
    add_index :mvw_domestic_search, :rrn, unique: true
  end

  def self.down; end
end

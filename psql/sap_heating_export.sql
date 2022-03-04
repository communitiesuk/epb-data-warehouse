--export for RdASAP & SAP with various sap heating nodes

SELECT CASE WHEN document ->> 'uprn' LIKE 'UPRN-%' THEN document ->> 'uprn' ELSE '' END as uprn,
       document ->> 'address_line_1' as address_line1,
       document ->> 'address_line_2' as address_line2,
       document ->> 'address_line_3' as address_line3,
       document ->> 'address_line_4' as address_line4,
       document ->> 'post_town' as town,
       document ->> 'postcode' as postcode,
       document -> 'sap_heating' -> 'cylinder_size' as cylinder_size,document -> 'sap_heating' -> 'cylinder_insulation_type' as cylinder_insulation_type,
       document -> 'sap_heating' -> 'has_cylinder_thermostat' as  has_cylinder_thermostat
FROM assessment_documents
WHERE (nullif(document->>'registration_date', '')::date) > ('20211001 00:00':: timestamp) AND (nullif(document->>'registration_date', '')::date) < ('2022-12-31 00:00':: timestamp)
  AND  (document ->> 'assessment_type')::varchar IN ('RdSAP', 'SAP');
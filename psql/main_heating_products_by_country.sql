SELECT COUNT(ad.assessment_id) count_valid_epcs,
     items -> 'main_heating_index_number' as main_heating_index_number,
     ad.document ->> 'country_code' as country_code,
     MAX(document ->> 'registration_date') as most_recent_lodgement,
     ex.numEPC as count_expired_epcs
FROM assessment_documents ad
CROSS JOIN LATERAL jsonb_array_elements(ad.document -> 'sap_heating' -> 'main_heating_details' ) as items
LEFT JOIN (SELECT COUNT(ad1.assessment_id) as numEPC,
              ad1.document ->> 'country_code' as country_code,
               items1 -> 'main_heating_index_number' as main_heating_index_number
      FROM assessment_documents ad1
      CROSS JOIN LATERAL jsonb_array_elements(ad1.document -> 'sap_heating' -> 'main_heating_details' ) as items1
      WHERE ad1.document ->> 'assessment_type' IN ('SAP', 'RdSAP')
      AND ad1.document ->> 'registration_date' < '2014-04-20'
      GROUP BY  items1 -> 'main_heating_index_number',  ad1.document ->> 'country_code'
      )
    ex ON items -> 'main_heating_details' = ex.main_heating_index_number and ad.document ->> 'country_code'= ex.country_code
WHERE ad.document ->> 'assessment_type' IN ('SAP', 'RdSAP')
AND items -> 'main_heating_index_number' IS NOT NULL
GROUP BY  items -> 'main_heating_index_number',  document ->> 'country_code',ex.numEPC




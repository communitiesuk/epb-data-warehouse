-- Query counting number of assessments with an EER value between A-C for different financial years

select
        CASE WHEN extract(month from (ad.document->>'registration_date')::date) >=4 THEN
          concat(extract(year from((ad.document->>'registration_date')::date)), '-',extract(year from((ad.document->>'registration_date')::date))+1)
        ELSE concat(extract(year from ((ad.document->>'registration_date')::date))-1,'-', extract(year from((ad.document->>'registration_date')::date))) END AS financial_year,
        count(CASE WHEN energy_band_calculator((ad.document->>'energy_rating_current')::int, 'sap') = 'A' THEN assessment_id
            END) as A,
        count(CASE WHEN energy_band_calculator((ad.document->>'energy_rating_current')::int, 'sap') = 'B' THEN assessment_id
            END) as B,
        count(CASE WHEN energy_band_calculator((ad.document->>'energy_rating_current')::int, 'sap') = 'C' THEN assessment_id
            END) as C
    from assessment_documents ad
    where (ad.document->>'registration_date' BETWEEN '2012-04-01' AND '2013-03-31')
    AND (ad.document ->> 'assessment_type')::varchar = 'SAP'
    AND ad.document ->> 'postcode' NOT LIKE 'BT%'
    AND (ad.document ->> 'transaction_type' = '6')
    AND ((ad.document->>'energy_rating_current')::int > 68)
    group by financial_year;
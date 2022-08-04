SELECT ad.document ->> 'address_line_1' as ADDRESS1,
    ad.document ->> 'address_line_2'  as ADDRESS2,
    ad.document ->> 'address_line_3'  as ADDRESS3,
    ad.document ->> 'postcode'  POSTCODE,
    CASE WHEN   ad.document ->> 'assessment_address_id' LIKE 'UPRN%' THEN   ad.document ->> 'assessment_address_id' ELSE '' END as BUILDING_REFERENCE_NUMBER,
        (ad.document ->> 'this_assessment')::json ->> 'energy_rating' as CURRENT_OPERATIONAL_RATING,
        (ad.document ->> 'year1_assessment')::json ->> 'energy_rating' as YR1_OPERATIONAL_RATING,´´
        (ad.document ->> 'year2_assessment')::json ->> 'energy_rating' as YR2_OPERATIONAL_RATING,
         CASE  WHEN ((ad.document ->> 'this_assessment')::json ->> 'energy_rating')::int <= 20 THEN 'g'
               WHEN ((ad.document ->> 'this_assessment')::json ->> 'energy_rating')::int BETWEEN 21 AND 38 THEN 'f'
               WHEN ((ad.document ->> 'this_assessment')::json ->> 'energy_rating')::int BETWEEN 39 AND 54 THEN 'e'
               WHEN ((ad.document ->> 'this_assessment')::json ->> 'energy_rating')::int BETWEEN 55 AND 68 THEN 'd'
                WHEN ((ad.document ->> 'this_assessment')::json ->> 'energy_rating')::int BETWEEN 69 AND 80 THEN 'c'
                WHEN ((ad.document ->> 'this_assessment')::json ->> 'energy_rating')::int BETWEEN 81 AND 91 THEN 'b'
        ELSE 'a' end  OPERATIONAL_RATING_BAND,
         (ad.document ->> 'this_assessment')::json ->> 'electricity_co2' ELECTRIC_CO2,
        (ad.document ->> 'this_assessment')::json ->> 'heating_co2' HEATING_CO2,
          (ad.document ->> 'this_assessment')::json ->> 'renewables_co2' renewables_CO2,
        ad.document ->> 'property_type' PROPERTY_TYPE,
        ad.document ->> 'inspection_date' Inspection_Date,
        ad.document ->> 'registration_date'  LODGEMENT_DATE,
        (ad.document ->> 'or_benchmark_data')::json ->> 'main_benchmark' MAIN_BENCHMARK,
       (ad.document ->> 'technical_information')::json ->> 'main_heating_fuel' MAIN_HEATING_FUEL,
        (ad.document ->> 'technical_information')::json ->> 'other_fuel_description' OTHER_FUEL,
       nullif((ad.document ->> 'technical_information')::json ->> 'special_energy_uses', '') SPECIAL_ENERGY_USES,
        (ad.document ->> 'dec_annual_energy_summary')::json ->> 'renewables_fuel_thermal' RENEWABLE_SOURCES,
      (ad.document ->> 'technical_information')::json ->> 'floor_area'  TOTAL_FLOOR_AREA,
        (ad.document ->> 'dec_annual_energy_summary')::json ->> 'annual_energy_use_fuel_thermal' ANNUAL_THERMAL_FUEL_USAGE,
         (ad.document ->> 'dec_annual_energy_summary')::json ->> 'typical_thermal_use' TYPICAL_THERMAL_FUEL_USAGE,
         (ad.document ->> 'dec_annual_energy_summary')::json ->> 'annual_energy_use_electrical' ANNUAL_THERMAL_FUEL_USAGE,
       (ad.document ->> 'dec_annual_energy_summary')::json ->> 'typical_electrical_use' typical_electrical_fuel_usage,
            (ad.document ->> 'dec_annual_energy_summary')::json ->> 'renewables_fuel_thermal' renewables_fuel_thermal,
       (ad.document ->> 'dec_annual_energy_summary')::json ->> 'renewables_electrical' renewables_electrical,
       (ad.document ->> 'year1_assessment')::json ->> 'electricity_co2' as YR1_electricity_co2,
         (ad.document ->> 'year2_assessment')::json ->> 'electricity_co2' as YR2_electricity_co2,
             (ad.document ->> 'year1_assessment')::json ->> 'heating_co2' as YR1_heating_co2,
          (ad.document ->> 'year2_assessment')::json ->> 'heating_co2' as YR2_heating_co2,
        (ad.document ->> 'year1_assessment')::json ->> 'renewables_co2' as YR1_renewables_co2,
       (ad.document ->> 'year2_assessment')::json ->> 'renewables_co2' as YR2_renewables_co2,
        (ad.document ->> 'ac_questionnaire')::json ->> 'ac_present' as aircon_present,
       nullif(((ad.document ->> 'ac_questionnaire')::json ->> 'ac_rated_output')::json ->> 'ac_kw_rating', '') AIRCON_KW_RATING,
       nullif((ad.document ->> 'ac_questionnaire')::json ->> 'ac_estimated_output', '') ESTIMATED_AIRCON_KW_RATING,
        nullif((ad.document ->> 'ac_questionnaire')::json ->> 'ac_inspection_commissioned', '') as AC_INSPECTION_COMMISSIONED,
           (ad.document ->> 'technical_information')::json ->> 'building_environment' BUILDING_ENVIRONMENT,
          ad.document ->> 'building_category'  BUILDING_CATEGORY,
        (ad.document ->> 'this_assessment')::json ->> 'nominated_date' nominated_date,
        ad.document ->> 'or_assessment_end_date' OR_ASSESSMENT_END_DATE,
        nullif(ad.document ->> 'created_at', '')  LODGEMENT_DATETIME,
        nullif(((json_array_elements( (ad.document -> ('or_benchmark_data') ->> 'benchmarks')::json))::json  ->> 'benchmark')::json ->> 'occupancy_level', '') OCCUPANCY_LEVEL
FROM assessment_documents ad
WHERE ad.document ->> 'assessment_type' = 'DEC'
AND (nullif(document->>'registration_date', '')::date) > ('2012-01-01 00:00':: timestamp)
  and   ad.document ->> 'postcode' LIKE 'BT%';
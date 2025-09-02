class CreateMvwCommercialRrSearch < ActiveRecord::Migration[7.0]
  def self.up
    sql = <<~SQL
      SELECT
          r.certificate_number AS CERTIFICATE_NUMBER,
          r.payback_type AS PAYBACK_TYPE,
          ROW_NUMBER() OVER (PARTITION BY r.certificate_number) AS RECOMMENDATION_ITEM,
          r.co2_impact AS CO2_IMPACT,
          r.recommendation_code AS RECOMMENDATION_CODE,
          r.recommendation AS RECOMMENDATION
      FROM (
              SELECT
                  s.related_rrn as CERTIFICATE_NUMBER,
                  REPLACE(attribute_name, '_payback', '') AS PAYBACK_TYPE,
                  items.co2_impact  as CO2_IMPACT,
                  items.recommendation_code as RECOMMENDATION_CODE,
                  items.recommendation as RECOMMENDATION
              FROM assessment_attribute_values aav
              CROSS JOIN LATERAL json_to_recordset(
                  CASE
                    WHEN jsonb_typeof(json::jsonb) = 'array' THEN aav.json::json
                    ELSE json_build_array(aav.json -> 'improvement')::json
                  END) AS
                items(co2_impact varchar, recommendation_code varchar, recommendation varchar)
              JOIN public.assessment_attributes aa ON aa.attribute_id = aav.attribute_id
              JOIN (
                  SELECT aav1.assessment_id, aav1.attribute_value as related_rrn
                  FROM assessment_attribute_values aav1
                  JOIN public.assessment_attributes a1 on aav1.attribute_id = a1.attribute_id
                  WHERE a1.attribute_name = 'related_rrn'
              ) s ON s.assessment_id = aav.assessment_id
              JOIN assessment_search ase ON ase.assessment_id = s.related_rrn
              JOIN assessments_country_ids aci ON aav.assessment_id = aci.assessment_id
              JOIN countries co ON aci.country_id = co.country_id
              WHERE attribute_name LIKE '%payback'
              AND  co.country_code IN ('EAW', 'ENG', 'WLS')
              AND  ase.assessment_type = 'CEPC'
      ) r
    SQL
    execute(sql)
  end

  def self.down; end
end

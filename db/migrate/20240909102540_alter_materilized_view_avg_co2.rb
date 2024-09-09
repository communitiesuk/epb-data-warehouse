class AlterMaterilizedViewAvgCo2 < ActiveRecord::Migration[7.0]
  def self.up
    execute "DROP MATERIALIZED VIEW IF EXISTS mvw_avg_co2_emissions"
    execute "CREATE SEQUENCE avg_co2_emissions_seq INCREMENT 1 START 1;"

    execute <<~SQL
      CREATE MATERIALIZED VIEW mvw_avg_co2_emissions
             AS
           SELECT#{' '}
               nextval('avg_co2_emissions_seq') as id,
               avg((ad.document ->> 'co2_emissions_current_per_floor_area')::float) as avg_co2_emission,
                  to_char((ad.document ->> 'registration_date')::date, 'YYYY-MM') as year_month,                                                   CASE WHEN co.country_code IN ('ENG', 'WLS', 'NIR') THEN co.country_name
                        WHEN co.country_code = 'EAW' then 'England' ELSE 'Other' END AS country
      #{'  '}
           FROM assessment_documents ad
           join assessments_country_ids aci on ad.assessment_id = aci.assessment_id
           join countries co on aci.country_id = co.country_id
           where (document ->> 'assessment_type')::varchar = 'SAP'
           and (ad.document ->> 'registration_date') >= '2020-10-01'
           group by year_month, country
           WITH NO DATA;
    SQL

    execute "CREATE UNIQUE INDEX idx_mvw_avg_co2_emissions ON mvw_avg_co2_emissions(id)"
  end

  def self.down
    execute "DROP INDEX IF EXISTS idx_mvw_avg_co2_emissions"
    execute "DROP MATERIALIZED VIEW IF EXISTS mvw_avg_co2_emissions"
    execute "DROP SEQUENCE IF EXISTS avg_co2_emissions_seq"
  end
end

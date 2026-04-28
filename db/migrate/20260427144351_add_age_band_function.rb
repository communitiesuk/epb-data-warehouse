class AddAgeBandFunction < ActiveRecord::Migration[8.1]
  def self.sql
    <<~SQL
      CREATE OR REPLACE FUNCTION fn_construction_age_band(document jsonb, assessment_type character varying, version character varying ) RETURNS varchar
                     language plpgsql
                     as
                     $$
                       DECLARE
                       construction_age varchar;
                       construction_age_band varchar;
                       construction_year varchar;

                       BEGIN
                           construction_age := COALESCE(document -> 'sap_building_parts' -> 0 ->> 'construction_age_band',  document -> 'sap_building_parts' -> 1 ->> 'construction_age_band');
                           construction_year :=  COALESCE(document -> 'sap_building_parts' -> 0 ->> 'construction_year',  document -> 'sap_building_parts' -> 1 ->> 'construction_year');
                           IF construction_age IS NOT NULL THEN
                                  construction_age_band := public.get_lookup_value('construction_age_band', construction_age, assessment_type, version);
                             ELSEIF construction_year IS NOT NULL THEN
                                 construction_age_band := construction_year;
                            END IF;

                             return construction_age_band;
                       END

           $$
    SQL
  end

  def self.up
    execute sql
  end

  def self.down; end
end

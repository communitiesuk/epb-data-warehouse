class AddEnergyBandCalculatorFunction < ActiveRecord::Migration[7.0]
  def self.up
    execute("CREATE OR REPLACE  function energy_band_calculator(energy_rating_current integer, assessment_type character varying) returns character varying
    language plpgsql
as
$$
DECLARE
energy_band varchar;

BEGIN
IF lower(assessment_type) LIKE '%sap'
    THEN
       IF energy_rating_current  <= 20 THEN  energy_band ='G';
        ELSEIF energy_rating_current BETWEEN 21 AND 38 THEN  energy_band ='F';
        ELSEIF energy_rating_current  BETWEEN 39 AND 54  THEN energy_band ='E';
        ELSEIF energy_rating_current BETWEEN 55 AND 68 THEN energy_band ='D';
        ELSEIF energy_rating_current BETWEEN 69 AND 80 THEN  energy_band ='C';
        ELSEIF energy_rating_current BETWEEN 81 AND 91 THEN  energy_band ='B';
        ELSE  energy_band = 'A';
    END IF;
ELSE
       IF energy_rating_current  <= -1 THEN  energy_band ='A+';
        ELSEIF energy_rating_current BETWEEN 0 AND 25 THEN  energy_band ='A';
        ELSEIF energy_rating_current  BETWEEN 26 AND 50  THEN energy_band ='B';
        ELSEIF energy_rating_current BETWEEN 51 AND 75 THEN energy_band ='C';
        ELSEIF energy_rating_current BETWEEN 76 AND 100 THEN  energy_band ='D';
        ELSEIF energy_rating_current BETWEEN 101 AND 125 THEN  energy_band ='E';
        ELSEIF energy_rating_current BETWEEN 126 AND 150 THEN  energy_band ='F';
        ELSE energy_band = 'G';
    END IF;
 END IF;


RETURN energy_band;

END $$;")
  end

  def self.down
    execute("DROP FUNCTION IF EXISTS energy_band_calculator")
  end
end

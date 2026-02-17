class CreateUprnSourceFunction < ActiveRecord::Migration[8.1]
  def self.up
    execute "CREATE OR REPLACE FUNCTION  fn_uprn_source(assessment_address_id varchar, matched_uprn bigint) returns character varying
    language plpgsql
as
$$
DECLARE

uprn_source varchar;

BEGIN
    IF starts_with(assessment_address_id, 'UPRN') THEN
        uprn_source = 'Energy Assessor';
    ELSEIF starts_with(assessment_address_id, 'RRN') and matched_uprn IS NOT NULL THEN
        uprn_source = 'Address Matched';
    END if;
RETURN uprn_source;

END $$;"
  end

  def self.down; end
end

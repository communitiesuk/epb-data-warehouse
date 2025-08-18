class AddCreatePartitionFunction < ActiveRecord::Migration[7.0]
  def self.up
    execute "CREATE OR REPLACE FUNCTION fn_create_day_month_partition(table_name text, end_year integer) RETURNS void
    language plpgsql
as
$$
     DECLARE
          partition_name varchar;
          start_date varchar;
          end_date varchar;
          sql text;



BEGIN


   FOR y IN 2012..end_year LOOP
       FOR m IN 1..12 LOOP
           start_date = make_date(y, m, 1)::varchar;
            IF m < 12 THEN
                end_date =  make_date(y, m+1, 1)::varchar ;
            ELSE
                end_date =  make_date(y+1, 1, 1)::varchar;
            END IF;
               partition_name = table_name || concat('_y', y, 'm', m);
             sql='CREATE TABLE ' || partition_name || ' PARTITION OF '|| table_name ||' FOR VALUES FROM (' || quote_literal(start_date) || ') TO  (' || quote_literal(end_date) ||')';
             EXECUTE sql;
         END LOOP;
   END LOOP;
END
$$;"
  end

  def self.down
    execute "DROP FUNCTION fn_create_day_month_partition"
  end
end

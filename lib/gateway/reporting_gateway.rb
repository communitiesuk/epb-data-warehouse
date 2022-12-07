module Gateway
  class ReportingGateway
    def initialize(assessment_attributes_gateway = nil)
      @assessment_attributes_gateway = assessment_attributes_gateway || Gateway::AssessmentAttributesGateway.new
    end

    def heat_pump_count_for_sap
      start_date = first_date_of_month_in_previous_year today
      end_date = last_date_of_previous_month today

      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "assessment_type_attribute_id",
          @assessment_attributes_gateway.get_attribute_id("main_heating").to_i,
          ActiveRecord::Type::Integer.new,
        ),

        ActiveRecord::Relation::QueryAttribute.new(
          "registered_date_attribute_id",
          @assessment_attributes_gateway.get_attribute_id("registration_date").to_i,
          ActiveRecord::Type::Integer.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "assessment_type_attribute_id",
          @assessment_attributes_gateway.get_attribute_id("assessment_type").to_i,
          ActiveRecord::Type::Integer.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "start_date",
          start_date,
          ActiveRecord::Type::DateTime.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "end_date",
          end_date,
          ActiveRecord::Type::DateTime.new,
        ),

      ]

      sql = <<-SQL
      SELECT COUNT(DISTINCT aav.assessment_id) num_epcs , to_char(date.registered_date::date, 'MM-YYYY') as month_year
      FROM assessment_attribute_values aav
       JOIN (SELECT aav1.assessment_id, json
                     FROM assessment_attribute_values aav1 WHERE attribute_id = $1) as heating
                    ON heating.assessment_id = aav.assessment_id
      JOIN (SELECT aav3.assessment_id, aav3.attribute_value as registered_date
                     FROM assessment_attribute_values aav3
                     WHERE aav3.attribute_id = $2)  as date
                    ON date.assessment_id = aav.assessment_id
       JOIN (SELECT aav1.assessment_id, attribute_value
                     FROM assessment_attribute_values aav1 WHERE attribute_id = $3) as type
                    ON type.assessment_id = aav.assessment_id
      WHERE type.attribute_value = 'SAP'
      AND To_DATE(date.registered_date, 'yyyy-mm-dd')  BETWEEN $4 AND $5
      AND (heating.json)::varchar LIKE '%heat pump%'
      GROUP BY to_char(date.registered_date::date, 'MM-YYYY');
      SQL

      results = ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)

      results.map { |result| result }
    end

  private

    def last_date_of_previous_month(date)
      Date.strptime(date.strftime("%Y-%m-01"), "%Y-%m-%d").prev_day
    end

    def first_date_of_month_in_previous_year(date)
      Date.strptime(date.prev_year.strftime("%Y-%m-01"), "%Y-%m-%d")
    end

    def today
      Date.today
    end
  end
end

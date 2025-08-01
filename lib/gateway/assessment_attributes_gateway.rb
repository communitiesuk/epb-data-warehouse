module Gateway
  class AssessmentAttributesGateway
    # TODO: Add rrn constant and set to "asessement_id"
    RRN = "assessment_id".freeze
    attr_accessor :attribute_columns_array

    def initialize
      @attribute_columns_array = []
    end

    def get_attribute_id(attribute_name)
      sql = <<-SQL
           SELECT attribute_id
            FROM assessment_attributes#{' '}
            WHERE attribute_name = $1
      SQL

      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "attribute_name",
          attribute_name,
          ActiveRecord::Type::String.new,
        ),
      ]

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings).first["attribute_id"]
    end

    def add_attribute(attribute_name:, parent_name: nil)
      attribute_data = fetch_attribute_id(attribute_name:, parent_name:)
      if attribute_data.nil?
        insert_attribute(attribute_name:, parent_name:)
      else
        attribute_data["attribute_id"]
      end
    end

    def add_attribute_value(
      assessment_id:,
      attribute_name:,
      attribute_value:,
      parent_name: nil
    )
      if !attribute_value.to_s.empty? && attribute_name.to_s != RRN
        begin
          ActiveRecord::Base.transaction do
            attribute_id = attributes.id_for(attribute_name, parent_name:)
            insert_attribute_value(
              assessment_id:,
              attribute_id:,
              attribute_value:,
            )
          end
        rescue ActiveRecord::RecordNotUnique
          raise Boundary::DuplicateAttribute, attribute_name
        end
      end
    end

    def add_attribute_values(*attribute_values, assessment_id:)
      values = attribute_values.reduce([]) do |carry, value|
        cast_value = CastValue.new value.value
        carry + [assessment_id, attributes.id_for(value.name, parent_name: value.parent_name), cast_value.string, cast_value.int, cast_value.float, cast_value.json ? JSON.fast_generate(cast_value.json) : nil]
      end
      sql = ActiveRecord::Base.sanitize_sql_array(
        ["INSERT INTO assessment_attribute_values (assessment_id, attribute_id, attribute_value, attribute_value_int, attribute_value_float, json) VALUES #{['(?,?,?,?,?,?)'] * attribute_values.length * ','} ON CONFLICT DO NOTHING"] + values,
      )
      ActiveRecord::Base.connection.exec_query(sql)
    rescue ActiveRecord::RecordNotUnique
      raise Boundary::BadAttributesWrite, "Error writing attributes for RRN #{assessment_id}"
    end

    def fetch_attribute_by_assessment(assessment_id:, attribute:)
      sql = <<-SQL
           SELECT aav.attribute_value#{' '}
            FROM assessment_attribute_values aav
            JOIN assessment_attributes aa ON aav.attribute_id = aa.attribute_id
            AND aa.attribute_name = $1 AND aav.assessment_id = $2
      SQL
      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "attribute_name",
          attribute,
          ActiveRecord::Type::String.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "assessment_id",
          assessment_id,
          ActiveRecord::Type::String.new,
        ),
      ]

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings).first["attribute_value"]
    end

    def assessment_exists(assessment_id)
      sql = <<-SQL
         SELECT EXISTS (SELECT * FROM assessment_attribute_values WHERE assessment_id = $1) as bool;
      SQL

      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "assessment_id",
          assessment_id,
          ActiveRecord::Type::String.new,
        ),
      ]

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings).first["bool"]
    end

    def delete_attributes_by_assessment(assessment_id)
      sql = <<-SQL
              DELETE FROM assessment_attribute_values
              WHERE assessment_id = $1
      SQL

      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "assessment_id",
          assessment_id,
          ActiveRecord::Type::String.new,
        ),
      ]

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)
    end

    def delete_attribute_value(attribute_name:, assessment_id:)
      sql = <<-SQL
             DELETE FROM assessment_attribute_values
              USING assessment_attributes
              WHERE  assessment_attribute_values.attribute_id = assessment_attributes.attribute_Id
              AND assessment_id = $1 AND attribute_name = $2
      SQL

      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "assessment_id",
          assessment_id,
          ActiveRecord::Type::String.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "attribute_name",
          attribute_name,
          ActiveRecord::Type::String.new,
        ),
      ]

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)
    end

    def fetch_assessments_to_add
      sql = <<-SQL
             SELECT a.assessment_id
              FROM assessments a
              WHERE NOT EXISTS (
                  SELECT * FROM assessment_attribute_values av WHERE av.assessment_id = a.assessment_id
            )
      SQL

      ActiveRecord::Base
        .connection
        .exec_query(sql, "SQL")
        .map { |result| result }
    end

    def fetch_assessment_attributes(
      attribute_column_array:,
      where_clause_hash: ""
    )
      # SELECT assessment_id, COALESCE(address1, '') as address1, COALESCE(address2, '') as address2, COALESCE(address3, '') as address3, , COALESCE(building_reference_number, '') as building_reference_number
      # FROM crosstab($$
      # SELECT  assessment_id, attribute_name, attribute_value
      # FROM assessment_attribute_values av
      # JOIN assessment_attributes a ON av.attribute_id = a.attribute_id
      #  JOIN (SELECT  assessment_id FROM assessment_attributes aa
      #                     JOIN assessment_attribute_values aav on aa.attribute_id = aav.attribute_id
      #                     WHERE aa.attribute_name = 'address3' AND aav.attribute_value = 'Some County'
      #                     GROUP BY assessment_id) w ON W.assessment_Id = av.assessment_id
      # WHERE a.attribute_name IN ('address2','address3','address1', 'building_reference_number')
      # ORDER BY assessment_id, CASE attribute_name WHEN 'address1' THEN 1 WHEN 'address2' THEN 2 WHEN 'address3' THEN 3 ELSE 4 END
      # $$,
      # $$ SELECT * FROM ( values ('address1'), ('address2'), ('address3'), ('building_reference_number') ) a $$)
      # AS virtual_columns(assessment_id varchar, address1 varchar, address2 varchar, address3 varchar, building_reference_number varchar)

      @attribute_columns_array = attribute_column_array.sort
      where_clause = attribute_where_clause
      virtual_columns = virtual_column_types
      filter_assesements =
        if where_clause_hash.empty?
          ""
        else
          filter_assesements_where_clause(where_clause_hash)
        end
      sql = <<-SQL
              SELECT assessment_id, #{coalesce_colums}
              FROM crosstab(
              $$
              SELECT  av.assessment_id, a.attribute_name, av.attribute_value
              FROM assessment_attribute_values av
              JOIN assessment_attributes a ON av.attribute_id = a.attribute_id
              #{filter_assesements}
              WHERE a.attribute_name IN (#{where_clause})
              ORDER BY assessment_id, #{order_sequence}
              $$,
              $$ SELECT * FROM (values #{select_columns}) a $$)
            AS virtual_columns(#{virtual_columns})
      SQL

      results = ActiveRecord::Base.connection.exec_query(sql, "SQL")
      results.map { |result| result }
    end

    def filter_assesements_where_clause(where_clause_hash)
      <<-SQL
        JOIN (SELECT  aav.assessment_id
              FROM assessment_attributes aa
               JOIN assessment_attribute_values aav on aa.attribute_id = aav.attribute_id
              WHERE aa.attribute_name = '#{where_clause_hash.keys.first}' AND aav.attribute_value = '#{where_clause_hash[where_clause_hash.keys.first]}'
              GROUP BY aav.assessment_id) w
          ON W.assessment_Id = av.assessment_id
      SQL
    end

    def fetch_sum(attribute_name:, value_type: "int")
      sql = <<-SQL
        SELECT SUM(eav.attribute_value_#{value_type}) as #{attribute_name}
        FROM assessment_attributes a
        JOIN assessment_attribute_values eav ON a.attribute_id = eav.attribute_id
        WHERE a.attribute_name = $1
      SQL

      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "attribute_name",
          attribute_name,
          ActiveRecord::Type::String.new,
        ),
      ]

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings).first[
        attribute_name,
      ]
    end

    def fetch_average(attribute_name:, value_type: "int")
      sql = <<-SQL
        SELECT   to_char( AVG(attribute_value_#{value_type}), 'FM999999999.00') as #{attribute_name}
        FROM assessment_attributes a
        JOIN assessment_attribute_values eav ON a.attribute_id = eav.attribute_id
        WHERE a.attribute_name = $1
      SQL

      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "attribute_name",
          attribute_name,
          ActiveRecord::Type::String.new,
        ),
      ]

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings).first[
        attribute_name,
      ]
    end

    def update_assessment_attribute(assessment_id:, attribute:, value:)
      sql = <<-SQL
           UPDATE assessment_attribute_values aav
            SET attribute_value  = $1
            FROM assessment_attributes aa
            WHERE  aav.attribute_id = aa.attribute_id
            AND aa.attribute_name = $2 AND aav.assessment_id = $3
      SQL

      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "attribute_value",
          value,
          ActiveRecord::Type::String.new,
        ),

        ActiveRecord::Relation::QueryAttribute.new(
          "attribute_name",
          attribute,
          ActiveRecord::Type::String.new,
        ),

        ActiveRecord::Relation::QueryAttribute.new(
          "assessment_id",
          assessment_id,
          ActiveRecord::Type::String.new,
        ),
      ]

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)
    end

    def fetch_duplicate_attributes
      sql = <<-SQL
             WITH CTE AS
        (SELECT attribute_id, attribute_name,
            ROW_NUMBER()
            OVER( PARTITION BY attribute_name ORDER BY attribute_id) as row_number
            FROM assessment_attributes
        )
        SELECT attribute_id, attribute_name, row_number
        FROM CTE
        WHERE row_number > 1
        ORDER BY attribute_name
      SQL
      ActiveRecord::Base.connection.exec_query(sql, "SQL").map { |row| row }
    end

    def fix_duplicate_attributes(duplicate_attributes:)
      duplicate_attributes.each do |row|
        existing_attribute_id = row["attribute_id"]
        updated_attribute_id = get_attribute_id(row["attribute_name"])
        update_assessments_attribute_id(existing_attribute_id:, updated_attribute_id:)
        delete_attribute(attribute_id: existing_attribute_id)
      rescue ActiveRecord::StatementInvalid
        delete_attribute_value_by_id(attribute_id: existing_attribute_id)
        delete_attribute(attribute_id: existing_attribute_id)
      end
    end

  private

    def attribute_where_clause
      new_array = @attribute_columns_array.clone
      new_array.map! { |i| "'#{i}'" }
      new_array.join(",")
    end

    def virtual_column_types
      new_array = @attribute_columns_array.clone
      new_array = rrn_into_array(new_array)
      new_array.map! { |name| "#{name} varchar" }
      new_array.join(", ")
    end

    def select_columns
      select_array = @attribute_columns_array.map { |item| "('#{item}')" }
      select_array.join(",")
    end

    def coalesce_colums
      select_array =
        @attribute_columns_array.map do |item|
          "COALESCE(#{item}, '') as #{item}"
        end
      select_array.join(", ")
    end

    def order_sequence
      order_by_string = "CASE attribute_name "
      @attribute_columns_array.each_with_index do |value, index|
        order_by_string << " WHEN '#{value}' THEN #{index + 1}"
      end
      order_by_string << +" ELSE #{@attribute_columns_array.count + 1} END"
    end

    def rrn_into_array(column_array)
      position = column_array.find_index(RRN)
      if position.nil?
        column_array.insert(0, RRN)
      elsif position.positive?
        column_array.insert(0, column_array.delete_at(position))
      end
      column_array
    end

    def fetch_attribute_id(attribute_name:, parent_name:)
      bindings = attribute_name_binding(attribute_name)

      if parent_name.nil? || parent_name.empty?
        sql = <<-SQL
             SELECT attribute_id
              FROM assessment_attributes WHERE attribute_name = $1
              LIMIT 1
        SQL
      else
        sql = <<-SQL
             SELECT attribute_id
              FROM assessment_attributes WHERE attribute_name = $1 AND parent_name = $2
              LIMIT 1
        SQL

        bindings <<
          ActiveRecord::Relation::QueryAttribute.new(
            "parent_name",
            parent_name,
            ActiveRecord::Type::String.new,
          )
      end

      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings).first
    end

    def attribute_name_binding(attribute_name)
      [ActiveRecord::Relation::QueryAttribute.new(
        "attribute_name",
        attribute_name,
        ActiveRecord::Type::String.new,
      )]
    end

    def insert_attribute(attribute_name:, parent_name:)
      bindings = attribute_name_binding(attribute_name)

      bindings <<
        ActiveRecord::Relation::QueryAttribute.new(
          "parent_name",
          parent_name,
          ActiveRecord::Type::String.new,
        )

      insert_sql = <<-SQL
              INSERT INTO assessment_attributes(attribute_name,parent_name )
              VALUES($1, $2)
      SQL

      ActiveRecord::Base.connection.insert(
        insert_sql,
        nil,
        nil,
        nil,
        nil,
        bindings,
      )
    end

    def valid_json?(input)
      JSON.parse(input)
      true
    rescue StandardError
      false
    end

    def insert_attribute_value(assessment_id:, attribute_id:, attribute_value:)
      sql = <<-SQL
              INSERT INTO assessment_attribute_values(assessment_id, attribute_id, attribute_value, attribute_value_int, attribute_value_float, json)
              VALUES($1, $2, $3, $4, $5, $6)
      SQL

      cast_value = CastValue.new attribute_value

      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "assessment_id",
          assessment_id,
          ActiveRecord::Type::String.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "attribute_id",
          attribute_id,
          ActiveRecord::Type::BigInteger.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "attribute_value",
          cast_value.string,
          ActiveRecord::Type::String.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "attribute_int",
          cast_value.int,
          ActiveRecord::Type::BigInteger.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "attribute_float",
          cast_value.float,
          ActiveRecord::Type::Decimal.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "json",
          cast_value.json,
          ActiveRecord::Type::Json.new,
        ),
      ]

      ActiveRecord::Base.connection.insert(sql, nil, nil, nil, nil, bindings)
    end

    def update_assessments_attribute_id(existing_attribute_id:, updated_attribute_id:)
      sql = <<-SQL
             UPDATE assessment_attribute_values
             SET attribute_id = $2
             WHERE attribute_id = $1
      SQL
      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "existing_attribute_id",
          existing_attribute_id,
          ActiveRecord::Type::BigInteger.new,
        ),
        ActiveRecord::Relation::QueryAttribute.new(
          "updated_attribute_id",
          updated_attribute_id,
          ActiveRecord::Type::BigInteger.new,
        ),
      ]
      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)
    end

    def delete_attribute(attribute_id:)
      sql = <<-SQL
             DELETE FROM assessment_attributes
             WHERE attribute_id = $1
      SQL
      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "attribute_id",
          attribute_id,
          ActiveRecord::Type::BigInteger.new,
        ),
      ]
      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)
    end

    def delete_attribute_value_by_id(attribute_id:)
      sql = <<-SQL
               DELETE FROM assessment_attribute_values
               WHERE attribute_id = $1
      SQL
      bindings = [
        ActiveRecord::Relation::QueryAttribute.new(
          "attribute_id",
          attribute_id,
          ActiveRecord::Type::BigInteger.new,
        ),
      ]
      ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)
    end

    def attributes
      Attributes.singleton
    end

    class Attributes
      class << self
        def singleton
          @singleton ||= fetch_attributes
        end

        def fetch_attributes
          sql = "SELECT attribute_id, attribute_name, parent_name FROM assessment_attributes"
          new(
            Concurrent::Map.new.marshal_load(
              Hash[
                ActiveRecord::Base.connection.exec_query(sql).map do |row|
                  [[row["attribute_name"], row["parent_name"]], row["attribute_id"]]
                end,
              ],
            ),
          )
        end

        def reset!
          @singleton = nil
        end
      end

      def initialize(attributes)
        raise ArgumentError unless attributes.is_a?(Concurrent::Map)

        @attributes = attributes
      end

      def [](key)
        attributes[key]
      end

      def id_for(attribute_name, parent_name: nil)
        attributes.compute_if_absent([attribute_name, parent_name]) do
          insert(attribute: attribute_name, parent: parent_name)
        end
      end

      attr_reader :attributes

    private

      def insert(attribute:, parent:)
        sql = "INSERT INTO assessment_attributes (attribute_name, parent_name) VALUES ($1, $2)"
        bindings = [
          ActiveRecord::Relation::QueryAttribute.new(
            "attribute_name",
            attribute,
            ActiveRecord::Type::String.new,
          ),
          ActiveRecord::Relation::QueryAttribute.new(
            "parent_name",
            parent,
            ActiveRecord::Type::String.new,
          ),
        ]
        ActiveRecord::Base.connection.insert(sql, nil, nil, nil, nil, bindings)
      end
    end

    class << self
      def reset!
        Attributes.reset!
      end
    end

    class CastValue
      def initialize(value)
        @value = value
      end

      def string
        value.to_s unless is_hash
      end

      def int
        value_as_int unless is_hash
      end

      def float
        value_as_float unless is_hash
      end

      def json
        value if is_hash
      end

    private

      attr_reader :value

      def value_as_int
        within_integer_range? ? value.to_i : nil
      rescue StandardError
        nil
      end

      def value_as_float
        value.to_f.zero? ? nil : value.to_f
      rescue StandardError
        nil
      end

      def within_integer_range?
        (["0", 0, 0.0].include?(value) || !value.to_i.zero?) && value.to_i < ((2**31) - 1) && value.to_i > -(2**31)
      end

      def is_hash
        value.respond_to?(:to_h)
      end
    end
  end
end

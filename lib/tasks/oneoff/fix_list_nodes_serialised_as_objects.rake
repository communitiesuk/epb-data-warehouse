module FixListNodesSerialisedAsObjects
  unless defined?(NODES_TO_FIX)
    NODES_TO_FIX = [
      {
        attribute_name: "pv_batteries",
        document_path: "'{sap_energy_source,pv_batteries}'",
        doc_value_expr: "ad.document->'sap_energy_source'->'pv_batteries'",
        eav_attribute_name: "sap_energy_source",
        eav_json_path: "'{pv_batteries}'",
        eav_value_expr: "aav.json->'pv_batteries'",
      },
      {
        attribute_name: "shower_outlets",
        document_path: "'{sap_heating,shower_outlets}'",
        doc_value_expr: "ad.document->'sap_heating'->'shower_outlets'",
        eav_attribute_name: "sap_heating",
        eav_json_path: "'{shower_outlets}'",
        eav_value_expr: "aav.json->'shower_outlets'",
      },
      {
        attribute_name: "alternative_improvements",
        document_path: "'{alternative_improvements}'",
        doc_value_expr: "ad.document->'alternative_improvements'",
        eav_attribute_name: "alternative_improvements",
        eav_json_path: nil,
        eav_value_expr: "aav.json",
      },
    ].freeze
  end

  unless defined?(FIRST_YEAR)
    FIRST_YEAR = 2012
  end

  def self.years_to_process(start_year:, end_year:)
    resolved_start = start_year || FIRST_YEAR
    resolved_end   = end_year || Date.today.year

    raise ArgumentError, "START_YEAR (#{resolved_start}) must be less than or equal to END_YEAR (#{resolved_end})" if resolved_start > resolved_end

    (resolved_start..resolved_end).to_a
  end

  def self.fetch_broken_assessment_ids(year:, node:)
    sql = <<~SQL
      SELECT ad.assessment_id
      FROM assessment_documents ad
      JOIN assessment_search s ON s.assessment_id = ad.assessment_id
      WHERE EXTRACT(YEAR FROM s.registration_date) = $1
        AND jsonb_typeof(#{node[:doc_value_expr]}) = 'object'
    SQL

    bindings = [
      ActiveRecord::Relation::QueryAttribute.new(
        "year",
        year,
        ActiveRecord::Type::Integer.new,
      ),
    ]

    ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings).map { |row| row["assessment_id"] }
  end

  def self.fetch_broken_eav_assessment_ids(year:, node:)
    sql = <<~SQL
      SELECT aav.assessment_id
      FROM assessment_attribute_values aav
      JOIN assessment_attributes aa ON aav.attribute_id = aa.attribute_id
      JOIN assessment_search s ON s.assessment_id = aav.assessment_id
      WHERE EXTRACT(YEAR FROM s.registration_date) = $1
        AND aa.attribute_name = $2
        AND jsonb_typeof(#{node[:eav_value_expr]}) = 'object'
    SQL

    bindings = [
      ActiveRecord::Relation::QueryAttribute.new(
        "year",
        year,
        ActiveRecord::Type::Integer.new,
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "attribute_name",
        node[:eav_attribute_name],
        ActiveRecord::Type::String.new,
      ),
    ]

    ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings).map { |row| row["assessment_id"] }
  end

  def self.update_json(assessment_ids:, node:)
    return if assessment_ids.empty?

    sql = <<~SQL
      UPDATE assessment_documents ad
      SET document = JSONB_SET(
        ad.document,
        #{node[:document_path]},
        jsonb_build_array(#{node[:doc_value_expr]})
      )
      WHERE ad.assessment_id = ANY($1)
    SQL

    bindings = [
      ActiveRecord::Relation::QueryAttribute.new(
        "assessment_ids",
        assessment_ids,
        ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array.new(ActiveRecord::Type::String.new),
      ),
    ]

    ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)
  end

  def self.update_eav(assessment_ids:, node:)
    return if assessment_ids.empty?

    sql = if node[:eav_json_path].nil?
            <<~SQL
              UPDATE assessment_attribute_values aav
              SET json = jsonb_build_array(#{node[:eav_value_expr]})
              FROM assessment_attributes aa
              WHERE aav.attribute_id = aa.attribute_id
                AND aav.assessment_id = ANY($1)
                AND aa.attribute_name = $2
                AND jsonb_typeof(#{node[:eav_value_expr]}) = 'object'
            SQL
          else
            <<~SQL
              UPDATE assessment_attribute_values aav
              SET json = jsonb_set(
                aav.json,
                #{node[:eav_json_path]},
                jsonb_build_array(#{node[:eav_value_expr]})
              )
              FROM assessment_attributes aa
              WHERE aav.attribute_id = aa.attribute_id
                AND aav.assessment_id = ANY($1)
                AND aa.attribute_name = $2
                AND jsonb_typeof(#{node[:eav_value_expr]}) = 'object'
            SQL
          end

    bindings = [
      ActiveRecord::Relation::QueryAttribute.new(
        "assessment_ids",
        assessment_ids,
        ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array.new(ActiveRecord::Type::String.new),
      ),
      ActiveRecord::Relation::QueryAttribute.new(
        "attribute_name",
        node[:eav_attribute_name],
        ActiveRecord::Type::String.new,
      ),
    ]

    ActiveRecord::Base.connection.exec_query(sql, "SQL", bindings)
  end
end

namespace :one_off do
  desc "Update pv_batteries, shower_outlets and alternative_improvements list nodes serialised as objects instead of arrays in the document store and EAV table"
  task :fix_list_nodes_serialised_as_objects do
    start_year = ENV["START_YEAR"]&.to_i
    end_year   = ENV["END_YEAR"]&.to_i

    years = FixListNodesSerialisedAsObjects.years_to_process(start_year:, end_year:)

    puts "Processing years: #{years.join(', ')}"

    years.each do |year|
      puts "Processing year: #{year}"

      FixListNodesSerialisedAsObjects::NODES_TO_FIX.each do |node|
        assessment_ids = FixListNodesSerialisedAsObjects.fetch_broken_assessment_ids(year:, node:)
        puts "  #{node[:attribute_name]}: #{assessment_ids.size} assessments to fix"
        next if assessment_ids.empty?

        FixListNodesSerialisedAsObjects.update_json(assessment_ids:, node:)
        FixListNodesSerialisedAsObjects.update_eav(assessment_ids:, node:)
      end
    end

    ActiveRecord::Base.connection.close
  end

  desc "Update pv_batteries, shower_outlets and alternative_improvements list nodes serialised as objects instead of arrays in the EAV table only"
  task :fix_list_nodes_serialised_as_objects_in_eav do
    start_year = ENV["START_YEAR"]&.to_i
    end_year   = ENV["END_YEAR"]&.to_i

    years = FixListNodesSerialisedAsObjects.years_to_process(start_year:, end_year:)

    puts "Processing years: #{years.join(', ')}"

    years.each do |year|
      puts "Processing year: #{year}"

      FixListNodesSerialisedAsObjects::NODES_TO_FIX.each do |node|
        assessment_ids = FixListNodesSerialisedAsObjects.fetch_broken_eav_assessment_ids(year:, node:)
        puts "  #{node[:attribute_name]}: #{assessment_ids.size} assessments to fix in EAV"
        next if assessment_ids.empty?

        FixListNodesSerialisedAsObjects.update_eav(assessment_ids:, node:)
      end
    end

    ActiveRecord::Base.connection.close
  end
end

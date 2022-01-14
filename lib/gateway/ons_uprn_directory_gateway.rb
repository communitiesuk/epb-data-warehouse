module Gateway
  class OnsUprnDirectoryGateway
    class VersionAlreadyExists < RuntimeError; end
    class InvalidMonth < RuntimeError; end

    # expects a month of format YYYY-MM e.g. "2022-01"
    def register_month(month)
      raise InvalidMonth unless /^2\d{3}-[0-1]\d$/.match?(month)

      write_sql = "INSERT INTO ons_uprn_directory_versions (version_month) VALUES ($1) RETURNING id"
      write_binds = [
        ActiveRecord::Relation::QueryAttribute.new(
          "version_month",
          month,
          ActiveRecord::Type::String.new,
        ),
      ]

      ActiveRecord::Base.connection.exec_query(write_sql, "SQL", write_binds).first["id"].to_s.to_sym
    rescue ActiveRecord::RecordNotUnique
      raise VersionAlreadyExists
    end

    def delete_month(month)
      delete_sql = "DELETE FROM ons_uprn_directory_versions WHERE version_month=$1"
      delete_binds = [
        ActiveRecord::Relation::QueryAttribute.new(
          "version_month",
          month,
          ActiveRecord::Type::String.new,
        ),
      ]

      ActiveRecord::Base.connection.exec_query(delete_sql, "SQL", delete_binds)
    end

    def insert_directory_data(data, version_id:)
      data.each_slice(500) do |slice|
        values = slice.reduce([]) do |carry, entry|
          carry + [canonicalize_uprn(entry[:uprn]), entry[:pcds], JSON.fast_generate(entry.except(:uprn, :pcds)), version_id]
        end
        sql = ActiveRecord::Base.send(
          :sanitize_sql_array,
          ["INSERT INTO ons_uprn_directory (uprn, postcode, areas, version_id) VALUES #{['(?,?,?,?)'] * slice.length * ', '}"] + values,
        )
        ActiveRecord::Base.connection.exec_query sql
      end
    end

  private

    def canonicalize_uprn(uprn)
      return uprn unless /^\d*$/.match?(uprn)

      "UPRN-#{uprn.rjust(12, '0')}"
    end
  end
end

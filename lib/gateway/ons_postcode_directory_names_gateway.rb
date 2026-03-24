module Gateway
  class OnsPostcodeDirectoryNamesGateway
    attr_reader :councils, :constituencies

    def initialize
      @data = fetch
      @councils = fetch_councils
      @constituencies = fetch_constituencies
    end

  private

    def fetch_councils
      @data = fetch.select { |i| i[:type] == "Local authority" }.map { |i| { name: i[:name], lower_name: i[:name].downcase } }
    end

    def fetch_constituencies
      @data = fetch.select { |i| i[:type] == "Westminster parliamentary constituency" }.map { |i| { name: i[:name], lower_name: i[:name].downcase } }
    end

    def fetch
      sql = <<-SQL
       SELECT DISTINCT name, id, type
        FROM ons_postcode_directory_names

        WHERE type in ('Local authority', 'Westminster parliamentary constituency')
      SQL
      ActiveRecord::Base.connection.exec_query(sql).map { |result| result.transform_keys(&:to_sym) }
    end
  end
end

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
      @data = fetch.select { |i| i["type"] == "Local authority" }
    end

    def fetch_constituencies
      @data = fetch.select { |i| i["type"] == "Westminster parliamentary constituency" }
    end

    def fetch
      sql = <<-SQL
       SELECT name, id, type
        FROM ons_postcode_directory_names

        WHERE type in ('Local authority', 'Westminster parliamentary constituency')
      SQL
      ActiveRecord::Base.connection.exec_query(sql).map { |result| result }
    end
  end
end

module Gateway
  class OnsPostcodeDirectoryNamesGateway
    def initialize
      @councils = fetch_councils
    end

    def fetch_council_id(name)
      @councils.find { |council| council["name"] == name }["id"]
    end

  private

    def fetch_councils
      sql = <<-SQL
        SELECT name, id
        FROM ons_postcode_directory_names
        WHERE type = 'Local authority'
      SQL
      ActiveRecord::Base.connection.exec_query(sql).map { |result| result }
    end
  end
end

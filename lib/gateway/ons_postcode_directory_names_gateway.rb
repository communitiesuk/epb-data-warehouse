module Gateway
  class OnsPostcodeDirectoryNamesGateway
    def initialize
      @councils = fetch_councils
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

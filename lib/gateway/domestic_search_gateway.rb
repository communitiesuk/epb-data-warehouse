module Gateway
  class DomesticSearchGateway < Gateway::BaseSearchGateway
    def initialize
      @mvw_name = "mvw_domestic_search"
      super
    end

    def fetch_rrns(*args)
      this_args = args.first
      sql = <<~SQL
        SELECT rrn
        FROM mvw_domestic_search#{' '}
      SQL

      this_args[:bindings] = get_bindings(**this_args)
      this_args[:sql] = sql
      sql = search_filter(**this_args)

      ActiveRecord::Base.connection.exec_query(sql, "SQL", this_args[:bindings]).map { |result| result }
    end
  end
end

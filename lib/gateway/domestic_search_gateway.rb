module Gateway
  class DomesticSearchGateway < Gateway::BaseSearchGateway
    def initialize
      @mvw_name = "mvw_domestic_search"
      super
    end

    def fetch_rr(*args)
      this_args = args.first
      sql = <<~SQL
         SELECT rr.rrn,
        improvement_item,
        improvement_id,
        indicative_cost,
        improvement_summary_text,
        improvement_descr_text
        FROM mvw_domestic_rr_search rr
        JOIN mvw_domestic_search m ON m.rrn=rr.rrn
      SQL

      this_args[:bindings] = get_bindings(**this_args)
      this_args[:sql] = sql
      sql = search_filter(**this_args)

      ActiveRecord::Base.connection.exec_query(sql, "SQL", this_args[:bindings]).map { |result| result }
    end
  end
end

module UseCase
  class GetPagination
    attr_writer :number_of_rows

    def initialize(search_gateway:)
      @search_gateway = search_gateway
      @number_of_rows = 5000
    end

    def execute(*args)
      this_args = args[0]

      total_records = @search_gateway.count(**this_args)
      current_page = this_args.delete(:current_page)&.to_i
      total_pages = (total_records / @number_of_rows.to_f).ceil
      next_page = current_page + 1 unless current_page >= total_pages
      prev_page = current_page > 1 ? current_page - 1 : nil

      {
        "total_records": total_records,
        "current_page": current_page,
        "total_pages": total_pages,
        "next_page": next_page,
        "prev_page": prev_page,
      }
    end
  end
end

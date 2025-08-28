module UseCase
  class GetPagination
    attr_writer :row_limit

    def initialize(assessment_search_gateway:)
      @assessment_search_gateway = assessment_search_gateway
      @row_limit = 5000
    end

    def execute(*args)
      this_args = args[0]

      total_records = @assessment_search_gateway.count(**this_args.reject { |k, _v| k == :row_limit })
      raise Boundary::NoData, "assessment search" if total_records.zero?

      current_page = this_args.delete(:current_page)&.to_i
      total_pages = (total_records / @row_limit.to_f).ceil
      raise Errors::OutOfPaginationRangeError, total_pages if current_page > total_pages || current_page < 1

      next_page = current_page + 1 unless current_page >= total_pages
      prev_page = current_page > 1 ? current_page - 1 : nil

      {
        total_records: total_records,
        current_page: current_page,
        total_pages: total_pages,
        next_page: next_page,
        prev_page: prev_page,
        page_size: @row_limit,
      }
    end
  end
end

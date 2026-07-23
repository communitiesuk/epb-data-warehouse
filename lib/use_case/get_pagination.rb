module UseCase
  class GetPagination
    def initialize(assessment_search_gateway:)
      @assessment_search_gateway = assessment_search_gateway
    end

    def execute(row_limit: 5000, **args)
      total_records = @assessment_search_gateway.count(**args)
      raise Boundary::NoData, "assessment search" if total_records.zero?

      current_page = args[:current_page]&.to_i
      total_pages = (total_records / row_limit.to_f).ceil
      raise Errors::OutOfPaginationRangeError, total_pages if current_page > total_pages || current_page < 1

      next_page = current_page + 1 unless current_page >= total_pages
      prev_page = current_page > 1 ? current_page - 1 : nil

      {
        total_records: total_records,
        current_page: current_page,
        total_pages: total_pages,
        next_page: next_page,
        prev_page: prev_page,
        page_size: row_limit,
      }
    end
  end
end

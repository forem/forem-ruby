module Forem
  class ListObject
    include Enumerable

    attr_reader :data, :current_page, :per_page, :filters, :resource_class

    def initialize(data:, current_page:, per_page:, resource_class:, filters:, requestor:)
      @data = data
      @current_page = current_page
      @per_page = per_page
      @resource_class = resource_class
      @filters = filters
      @requestor = requestor
    end

    def has_more?
      @data.length == @per_page && @data.length > 0
    end

    def each(&block)
      @data.each(&block)
    end

    def auto_paging_each(&block)
      page = self
      loop do
        page.each(&block)
        break unless page.has_more?
        page = page.next_page
      end
    end

    def next_page(params = {})
      return nil unless has_more?
      fetch_page(@current_page + 1, params)
    end

    def previous_page(params = {})
      return nil if @current_page <= 1
      fetch_page(@current_page - 1, params)
    end

    private

    def fetch_page(page_num, extra_params = {})
      params = @filters.merge(page: page_num, per_page: @per_page).merge(extra_params)
      opts = @requestor ? { requestor: @requestor } : {}
      @resource_class.list(params, opts)
    end
  end
end

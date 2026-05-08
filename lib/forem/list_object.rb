module Forem
  # Wraps a paginated list of API resources returned by collection endpoints.
  #
  # {ListObject} implements +Enumerable+ so the current page's items can be
  # iterated with the standard Ruby collection methods. Use
  # {#auto_paging_each} to transparently iterate across all pages without
  # managing pagination manually.
  #
  # Two paging modes are supported:
  #
  # * *page-based* (default) — uses +page+/+per_page+ query params. Created
  #   by {APIOperations::List#list} and the +paginated_list+ helper on
  #   {APIResource}.
  # * *cursor-based* — uses an +after+-style cursor (e.g. survey poll
  #   endpoints). Created by the +cursor_list+ helper on {APIResource}.
  #
  # In both modes the public surface is the same: {#data}, {#has_more?},
  # {#each}, {#next_page}, {#auto_paging_each}.
  #
  # @example Iterating the current page
  #   articles = client.articles.list(per_page: 5)
  #   articles.each { |a| puts a.title }
  #
  # @example Iterating all pages automatically
  #   client.articles.list(per_page: 30).auto_paging_each do |article|
  #     puts article.title
  #   end
  class ListObject
    include Enumerable

    # @return [Array<ForemObject>] the resource objects on the current page.
    attr_reader :data

    # @return [Integer, nil] the 1-based current page number for page-based
    #   pagination, or +nil+ for cursor-based pagination.
    attr_reader :current_page

    # @return [Integer] the maximum number of items per page requested.
    attr_reader :per_page

    # @return [Hash] the non-pagination filter parameters used to build this
    #   list (e.g. +{ tag: "ruby" }+). These are forwarded when fetching
    #   subsequent pages.
    attr_reader :filters

    # @return [Class] the resource class used to construct items.
    attr_reader :resource_class

    # @return [APIRequestor, nil] the requestor that produced this list and
    #   that will be re-used for fetching additional pages.
    attr_reader :requestor

    # Create a new ListObject.
    #
    # @param data [Array<ForemObject>] the resource objects for this page.
    # @param per_page [Integer] the page size requested.
    # @param resource_class [Class] the resource class for this collection.
    # @param filters [Hash] the non-pagination query parameters.
    # @param requestor [APIRequestor, nil] the requestor used to fetch the
    #   current page; reused for subsequent pages.
    # @param current_page [Integer, nil] the 1-based current page number, or
    #   +nil+ for cursor-based pagination.
    # @param fetcher [Proc, nil] optional callable invoked with
    #   <tt>(direction, current_list, extra_params)</tt> to fetch the next or
    #   previous page. Used by custom-path or cursor-based endpoints. When
    #   +nil+, page-based pagination falls back to
    #   <tt>resource_class.list(...)</tt>.
    # @return [ListObject]
    def initialize(data:, per_page:, resource_class:, filters:, requestor:, current_page: nil, fetcher: nil)
      @data = data
      @current_page = current_page
      @per_page = per_page
      @resource_class = resource_class
      @filters = filters
      @requestor = requestor
      @fetcher = fetcher
    end

    # Return whether more pages of results may exist after this one.
    #
    # Inferred by checking whether the current page returned exactly
    # {#per_page} items.
    #
    # @return [Boolean]
    def has_more?
      @data.length == @per_page && @data.length > 0
    end

    # Iterate over the resource objects on the current page.
    #
    # @yield [ForemObject] each resource object on the current page.
    # @return [Enumerator] if no block is given.
    def each(&block)
      @data.each(&block)
    end

    # Indexed access to the underlying page data.
    # @param idx [Integer] zero-based item index within the current page.
    # @return [ForemObject, nil]
    def [](idx)
      @data[idx]
    end

    # @return [Integer] the number of items on the current page.
    def length
      @data.length
    end
    alias_method :size, :length

    # @return [Boolean] whether the current page contains zero items.
    def empty?
      @data.empty?
    end

    # Iterate over every resource across all pages, automatically fetching
    # subsequent pages as needed. Stops when {#has_more?} is false or
    # {#next_page} returns +nil+.
    #
    # @yield [ForemObject] each resource object across all pages.
    # @return [void]
    def auto_paging_each(&block)
      page = self
      loop do
        page.each(&block)
        break unless page.has_more?
        page = page.next_page
        break unless page
      end
    end

    # Fetch the next page of results.
    #
    # Returns +nil+ when {#has_more?} is +false+ or when the fetcher signals
    # there is no further page.
    #
    # @param params [Hash] additional parameters merged on top of {#filters}.
    # @return [ListObject, nil]
    def next_page(params = {})
      return nil unless has_more?
      if @fetcher
        @fetcher.call(:next, self, params)
      else
        fetch_page(@current_page + 1, params)
      end
    end

    # Fetch the previous page of results.
    #
    # Page-based: returns +nil+ when already on page 1.
    # Cursor-based: returns +nil+ (cursor pagination is forward-only).
    #
    # @param params [Hash] additional parameters merged on top of {#filters}.
    # @return [ListObject, nil]
    def previous_page(params = {})
      if @fetcher
        @fetcher.call(:previous, self, params)
      else
        return nil if @current_page.nil? || @current_page <= 1
        fetch_page(@current_page - 1, params)
      end
    end

    private

    def fetch_page(page_num, extra_params = {})
      params = @filters.merge(page: page_num, per_page: @per_page).merge(extra_params)
      opts = @requestor ? { requestor: @requestor } : {}
      @resource_class.list(params, opts)
    end
  end
end

module Forem
  # Wraps a paginated list of API resources returned by collection endpoints.
  #
  # {ListObject} implements +Enumerable+ so the current page's items can be
  # iterated with the standard Ruby collection methods. Use {#auto_paging_each}
  # to transparently iterate across all pages without managing pagination
  # manually.
  #
  # Instances are created by {APIOperations::List#list} and are not typically
  # constructed directly.
  #
  # @example Iterating the current page
  #   articles = Forem::Article.list(per_page: 5)
  #   articles.each { |a| puts a.title }
  #
  # @example Iterating all pages automatically
  #   Forem::Article.list(per_page: 30).auto_paging_each do |article|
  #     puts article.title
  #   end
  #
  # @example Manual pagination
  #   page1 = Forem::Article.list(per_page: 10)
  #   page2 = page1.next_page
  #   page2.previous_page  # back to page 1
  class ListObject
    include Enumerable

    # @return [Array<ForemObject>] the resource objects on the current page.
    attr_reader :data

    # @return [Integer] the 1-based index of the current page.
    attr_reader :current_page

    # @return [Integer] the maximum number of items per page requested.
    attr_reader :per_page

    # @return [Hash] the non-pagination filter parameters used to build this
    #   list (e.g. +{ tag: "ruby" }+). These are forwarded when fetching
    #   subsequent pages.
    attr_reader :filters

    # @return [Class] the resource class (e.g. +Forem::Article+) used to
    #   construct items and to issue page-fetch requests.
    attr_reader :resource_class

    # Create a new ListObject.
    #
    # @param data [Array<ForemObject>] the resource objects for this page.
    # @param current_page [Integer] the 1-based current page number.
    # @param per_page [Integer] the page size requested.
    # @param resource_class [Class] the resource class for this collection.
    # @param filters [Hash] the non-pagination query parameters.
    # @param requestor [APIRequestor, nil] an optional custom requestor to use
    #   when fetching additional pages. Pass +nil+ to use the default.
    # @return [ListObject]
    def initialize(data:, current_page:, per_page:, resource_class:, filters:, requestor:)
      @data = data
      @current_page = current_page
      @per_page = per_page
      @resource_class = resource_class
      @filters = filters
      @requestor = requestor
    end

    # Return whether there are likely more pages of results after this one.
    #
    # Infers the existence of a next page by checking whether the current
    # page returned exactly {#per_page} items. This heuristic means that if
    # the total count happens to be a multiple of {#per_page} the last page
    # will appear to have more results until fetched.
    #
    # @return [Boolean] +true+ if the current page is full and another page
    #   may exist.
    def has_more?
      @data.length == @per_page && @data.length > 0
    end

    # Iterate over the resource objects on the current page.
    #
    # Required by +Enumerable+. Delegates to the underlying +data+ array.
    #
    # @yield [ForemObject] each resource object on the current page.
    # @return [Enumerator] if no block is given.
    def each(&block)
      @data.each(&block)
    end

    # Iterate over every resource across all pages, automatically fetching
    # subsequent pages as needed.
    #
    # Fetches the next page only after all items on the current page have been
    # yielded, so network requests are made lazily. Stops when {#has_more?}
    # returns +false+.
    #
    # @yield [ForemObject] each resource object across all pages.
    # @return [void]
    #
    # @example
    #   Forem::Article.list.auto_paging_each do |article|
    #     process(article)
    #   end
    def auto_paging_each(&block)
      page = self
      loop do
        page.each(&block)
        break unless page.has_more?
        page = page.next_page
      end
    end

    # Fetch the next page of results.
    #
    # Returns +nil+ when {#has_more?} is +false+, indicating that the current
    # page is the last one.
    #
    # @param params [Hash] additional parameters to merge into the next-page
    #   request (merged on top of {#filters}).
    # @return [ListObject, nil] the next page as a new {ListObject}, or +nil+
    #   if there are no more pages.
    #
    # @example
    #   page2 = page1.next_page
    #   page3 = page2&.next_page
    def next_page(params = {})
      return nil unless has_more?
      fetch_page(@current_page + 1, params)
    end

    # Fetch the previous page of results.
    #
    # Returns +nil+ when already on the first page (<tt>current_page <= 1</tt>).
    #
    # @param params [Hash] additional parameters to merge into the request
    #   (merged on top of {#filters}).
    # @return [ListObject, nil] the previous page as a new {ListObject}, or
    #   +nil+ if already on page 1.
    #
    # @example
    #   page1 = page2.previous_page
    def previous_page(params = {})
      return nil if @current_page <= 1
      fetch_page(@current_page - 1, params)
    end

    private

    # Fetch an arbitrary page number from the API.
    #
    # Merges stored {#filters} with the target page number, {#per_page}, and
    # any extra params before delegating to {#resource_class}.list.
    #
    # @param page_num [Integer] the 1-based page number to fetch.
    # @param extra_params [Hash] additional parameters for the request.
    # @return [ListObject] the requested page.
    def fetch_page(page_num, extra_params = {})
      params = @filters.merge(page: page_num, per_page: @per_page).merge(extra_params)
      opts = @requestor ? { requestor: @requestor } : {}
      @resource_class.list(params, opts)
    end
  end
end

module Forem
  # Base object class for all Forem API objects. Provides dynamic attribute
  # access from API response data.
  #
  # Attributes are stored internally as a plain +Hash+ with string keys.
  # They can be read and written using either method-call syntax
  # (<tt>obj.title</tt>) or hash-subscript syntax (<tt>obj["title"]</tt>).
  # Nested hashes are recursively converted to {ForemObject} instances via
  # {Util.convert_to_forem_object}.
  #
  # @example Constructing from an API response hash
  #   obj = Forem::ForemObject.construct_from({ "id" => 1, "title" => "Hello" })
  #   obj.id      #=> 1
  #   obj.title   #=> "Hello"
  #   obj["title"] #=> "Hello"
  #
  # @example Writing attributes
  #   obj.title = "Updated"
  #   obj["title"] = "Updated again"
  class ForemObject
    include APIOperations::Request

    # @return [APIRequestor, nil] the requestor that produced this object,
    #   used by instance methods (e.g. {APIOperations::Save#save}) when no
    #   explicit +:requestor+ option is supplied.
    attr_accessor :requestor

    # Wrap a custom-path GET-array endpoint as a page-based {ListObject}.
    #
    # Used by resource methods that hit a non-standard path (e.g.
    # +/api/articles/me/published+) but otherwise behave like
    # {APIOperations::List#list}: page-based pagination with
    # +page+/+per_page+ query params, returning a JSON array of resource
    # objects.
    #
    # The returned ListObject re-uses this same helper for {#next_page} and
    # {#previous_page}, so pagination works without any further wiring.
    #
    # @param path [String] the API path to GET.
    # @param params [Hash] query parameters (filters and pagination).
    # @param opts [Hash] per-request options including +:requestor+.
    # @return [ListObject]
    def self.paginated_list(path, params = {}, opts = {})
      requestor = opts[:requestor]
      resp = request(:get, path, params, opts)
      per_page = (params[:per_page] || params["per_page"] || 30).to_i
      page = (params[:page] || params["page"] || 1).to_i
      klass = self
      data = (resp.parsed_body || []).map { |item| klass.construct_from(item, requestor: requestor) }

      fetcher = lambda do |direction, state, extra|
        target = direction == :next ? state.current_page + 1 : state.current_page - 1
        return nil if target < 1
        new_params = state.filters.merge(page: target, per_page: state.per_page).merge(extra)
        klass.paginated_list(path, new_params, { requestor: state.requestor })
      end

      ListObject.new(
        data: data,
        current_page: page,
        per_page: per_page,
        resource_class: klass,
        filters: params.reject { |k, _| [:page, :per_page, "page", "per_page"].include?(k) },
        requestor: requestor,
        fetcher: fetcher
      )
    end

    # Wrap a cursor-based ("after") GET-array endpoint as a {ListObject}.
    #
    # Used by endpoints (e.g. survey poll votes) that use an +after+-style
    # cursor — successive pages are fetched by passing the last seen ID as
    # the cursor. Cursor pagination is forward-only; {ListObject#previous_page}
    # returns +nil+.
    #
    # @param path [String] the API path to GET.
    # @param params [Hash] query parameters (filters and per_page).
    # @param opts [Hash] per-request options including +:requestor+.
    # @param cursor_param [Symbol] the query-string key for the cursor
    #   (default +:after+).
    # @param cursor_from [Proc] a callable returning the cursor value for an
    #   item (default extracts +"id"+).
    # @return [ListObject]
    def self.cursor_list(path, params = {}, opts = {}, cursor_param: :after, cursor_from: ->(item) { item["id"] })
      requestor = opts[:requestor]
      resp = request(:get, path, params, opts)
      per_page = (params[:per_page] || params["per_page"] || 30).to_i
      klass = self
      data = (resp.parsed_body || []).map { |item| klass.construct_from(item, requestor: requestor) }

      fetcher = lambda do |direction, state, extra|
        return nil unless direction == :next
        return nil if state.data.empty?
        next_cursor = cursor_from.call(state.data.last)
        new_params = state.filters.merge(cursor_param => next_cursor, per_page: state.per_page).merge(extra)
        klass.cursor_list(path, new_params, { requestor: state.requestor },
                          cursor_param: cursor_param, cursor_from: cursor_from)
      end

      ListObject.new(
        data: data,
        current_page: nil,
        per_page: per_page,
        resource_class: klass,
        filters: params.reject { |k, _| [cursor_param, cursor_param.to_s, :per_page, "per_page"].include?(k) },
        requestor: requestor,
        fetcher: fetcher
      )
    end

    # Initialise a new object, optionally pre-populating it with values.
    #
    # @param values [Hash] initial attribute hash. Keys are coerced to strings.
    # @return [ForemObject]
    def initialize(values = {})
      @values = {}
      @requestor = nil
      update_attributes(values)
    end

    # Construct a new {ForemObject} from an API response hash.
    #
    # This is the preferred factory method — it is called by {Util} and
    # resource class methods rather than {#initialize} directly.
    #
    # @param values [Hash] the API response data. Nested Hashes and Arrays
    #   are recursively converted via {Util.convert_to_forem_object}.
    # @param requestor [APIRequestor, nil] the requestor to attach so that
    #   subsequent instance methods (e.g. +article.save+) can issue
    #   follow-up calls without having to be passed a +:requestor+ opt
    #   explicitly.
    # @return [ForemObject] a new object populated with the given attributes.
    #
    # @example
    #   obj = Forem::ForemObject.construct_from({ "id" => 42, "user" => { "name" => "Alice" } })
    #   obj.user.name  #=> "Alice"
    def self.construct_from(values, requestor: nil)
      obj = new
      obj.send(:update_attributes, values)
      obj.requestor = requestor
      obj
    end

    # Read an attribute by key.
    #
    # @param key [String, Symbol] the attribute name. Symbols are coerced to
    #   strings before lookup.
    # @return [Object, nil] the stored value, or +nil+ if the key is absent.
    #
    # @example
    #   obj["id"]    #=> 42
    #   obj[:title]  #=> "Hello"
    def [](key)
      @values[key.to_s]
    end

    # Write an attribute by key.
    #
    # The value is passed through {Util.convert_to_forem_object} so nested
    # Hashes become {ForemObject} instances automatically.
    #
    # @param key [String, Symbol] the attribute name. Symbols are coerced to
    #   strings.
    # @param value [Object] the value to store.
    # @return [Object] the stored (possibly converted) value.
    #
    # @example
    #   obj["title"] = "New title"
    #   obj[:count]  = 5
    def []=(key, value)
      @values[key.to_s] = Util.convert_to_forem_object(value)
    end

    # Recursively convert this object to a plain Ruby Hash.
    #
    # Nested {ForemObject} instances are converted via their own +#to_hash+;
    # Arrays whose elements are {ForemObject} instances are mapped similarly.
    #
    # @return [Hash{String => Object}] a plain Hash representation of all
    #   attributes.
    #
    # @example
    #   obj.to_hash  #=> { "id" => 1, "title" => "Hello" }
    def to_hash
      @values.transform_values do |v|
        case v
        when ForemObject then v.to_hash
        when Array then v.map { |e| e.is_a?(ForemObject) ? e.to_hash : e }
        else v
        end
      end
    end

    # Compare two {ForemObject} instances by their internal value hash.
    #
    # @param other [Object] the object to compare against.
    # @return [Boolean] +true+ if +other+ is a {ForemObject} with identical
    #   attribute values.
    def ==(other)
      other.is_a?(ForemObject) && @values == other.instance_variable_get(:@values)
    end

    # Allow +respond_to?+ checks for dynamic attribute accessors.
    #
    # Returns +true+ for any key currently stored in the internal values hash,
    # as well as the corresponding setter (e.g. +title=+).
    #
    # @param method [Symbol] the method name being queried.
    # @param include_private [Boolean] whether to include private methods.
    # @return [Boolean]
    def respond_to_missing?(method, include_private = false)
      name = method.to_s
      name = name.chomp("=")
      @values.key?(name) || super
    end

    # Dynamic getter/setter for API attributes.
    #
    # * <tt>obj.title</tt>   — returns <tt>@values["title"]</tt>
    # * <tt>obj.title = x</tt> — delegates to {#[]=}
    #
    # Raises +NoMethodError+ for names that are neither setters nor present in
    # the values hash.
    #
    # @param method [Symbol] the missing method name.
    # @param args [Array] arguments (used only for setter calls).
    # @return [Object] the attribute value for getters.
    # @raise [NoMethodError] if the attribute does not exist in the values hash
    #   and it is not a setter call.
    def method_missing(method, *args)
      name = method.to_s
      if name.end_with?("=")
        attr = name.chomp("=")
        self[attr] = args[0]
      elsif @values.key?(name)
        @values[name]
      else
        super
      end
    end

    # Return a human-readable string representation of the object.
    #
    # @return [String] the class name, object ID, and internal values hash.
    def inspect
      "#<#{self.class}:0x#{object_id.to_s(16)} #{@values.inspect}>"
    end

    private

    # Bulk-update internal attributes from a hash.
    #
    # Each value is passed through {Util.convert_to_forem_object} so nested
    # structures are converted recursively.
    #
    # @param values [Hash] attribute key/value pairs to merge.
    # @return [void]
    def update_attributes(values)
      values.each do |k, v|
        @values[k.to_s] = Util.convert_to_forem_object(v)
      end
    end
  end
end

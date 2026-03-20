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
    # Initialise a new object, optionally pre-populating it with values.
    #
    # @param values [Hash] initial attribute hash. Keys are coerced to strings.
    # @return [ForemObject]
    def initialize(values = {})
      @values = {}
      update_attributes(values)
    end

    # Construct a new {ForemObject} from an API response hash.
    #
    # This is the preferred factory method — it is called by {Util} and
    # resource class methods rather than {#initialize} directly.
    #
    # @param values [Hash] the API response data. Nested Hashes and Arrays are
    #   recursively converted via {Util.convert_to_forem_object}.
    # @return [ForemObject] a new object populated with the given attributes.
    #
    # @example
    #   obj = Forem::ForemObject.construct_from({ "id" => 42, "user" => { "name" => "Alice" } })
    #   obj.user.name  #=> "Alice"
    def self.construct_from(values)
      obj = new
      obj.send(:update_attributes, values)
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

module Forem
  # Utility helpers used internally by the forem-ruby library.
  #
  # These methods are not part of the public API surface for end users but are
  # documented here for contributors and library maintainers.
  module Util
    # Recursively convert a raw Ruby value into the appropriate Forem type.
    #
    # The conversion rules are:
    # * +Hash+   → {ForemObject} (via {ForemObject.construct_from})
    # * +Array+  → Array with each element passed through this method
    # * anything else → returned unchanged
    #
    # This method is called during attribute assignment in {ForemObject} so
    # that nested API response hashes automatically become {ForemObject}
    # instances with dynamic attribute access.
    #
    # @param value [Object] the raw value to convert.
    # @return [ForemObject, Array, Object] the converted value.
    #
    # @example Converting a hash
    #   Forem::Util.convert_to_forem_object({ "id" => 1, "name" => "Alice" })
    #   #=> #<Forem::ForemObject ...>
    #
    # @example Converting an array of hashes
    #   Forem::Util.convert_to_forem_object([{ "id" => 1 }, { "id" => 2 }])
    #   #=> [#<Forem::ForemObject ...>, #<Forem::ForemObject ...>]
    #
    # @example Passing through a scalar value
    #   Forem::Util.convert_to_forem_object("hello")  #=> "hello"
    #   Forem::Util.convert_to_forem_object(42)       #=> 42
    def self.convert_to_forem_object(value)
      case value
      when Hash
        ForemObject.construct_from(value)
      when Array
        value.map { |v| convert_to_forem_object(v) }
      else
        value
      end
    end
  end
end

module Forem
  module Util
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

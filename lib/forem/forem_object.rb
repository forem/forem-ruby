module Forem
  class ForemObject
    def initialize(values = {})
      @values = {}
      update_attributes(values)
    end

    def self.construct_from(values)
      obj = new
      obj.send(:update_attributes, values)
      obj
    end

    def [](key)
      @values[key.to_s]
    end

    def []=(key, value)
      @values[key.to_s] = Util.convert_to_forem_object(value)
    end

    def to_hash
      @values.transform_values do |v|
        case v
        when ForemObject then v.to_hash
        when Array then v.map { |e| e.is_a?(ForemObject) ? e.to_hash : e }
        else v
        end
      end
    end

    def ==(other)
      other.is_a?(ForemObject) && @values == other.instance_variable_get(:@values)
    end

    def respond_to_missing?(method, include_private = false)
      name = method.to_s
      name = name.chomp("=")
      @values.key?(name) || super
    end

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

    def inspect
      "#<#{self.class}:0x#{object_id.to_s(16)} #{@values.inspect}>"
    end

    private

    def update_attributes(values)
      values.each do |k, v|
        @values[k.to_s] = Util.convert_to_forem_object(v)
      end
    end
  end
end

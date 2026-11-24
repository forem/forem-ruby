# frozen_string_literal: true

module ForemApiSync
  # Introspects the loaded Forem Ruby SDK (`Forem::Client`, services, and
  # resources) to verify that every endpoint mapping declared in
  # `.forem-api-sync.json` points to real, callable Ruby methods.
  class SdkIntrospector
    def initialize(lib_dir:)
      @lib_dir = File.expand_path(lib_dir)
      $LOAD_PATH.unshift(@lib_dir) unless $LOAD_PATH.include?(@lib_dir)
      require "forem"
    end

    # Validates a single `sdk` binding hash from `.forem-api-sync.json`.
    #
    # Supported fields:
    # - `client_accessor`: method on `Forem::Client` (e.g. `"articles"`)
    # - `service_method`: public instance method on the returned service (e.g. `"list"`)
    # - `resource`: constant name under `Forem` (e.g. `"Article"`)
    # - `resource_class_method`: public singleton method on resource class (optional)
    # - `resource_instance_method`: public instance method on resource class (optional)
    #
    # Returns an Array of error strings (empty when valid).
    def validate_binding(route_key, sdk)
      errors = []
      unless sdk.is_a?(Hash) && !sdk.empty?
        return ["#{route_key}: missing `sdk` mapping for implemented endpoint"]
      end

      client = Forem::Client.new("introspection-dummy-key")

      if (accessor = sdk["client_accessor"])
        if client.respond_to?(accessor)
          service = client.public_send(accessor)
          if (service_method = sdk["service_method"])
            unless service.respond_to?(service_method)
              errors << "#{route_key}: #{service.class}##{service_method} is not defined"
            end
          end
        else
          errors << "#{route_key}: Forem::Client##{accessor} is not defined"
        end
      end

      if (resource_name = sdk["resource"])
        if Forem.const_defined?(resource_name, false)
          resource_class = Forem.const_get(resource_name, false)

          if (cm = sdk["resource_class_method"])
            unless resource_class.respond_to?(cm)
              errors << "#{route_key}: Forem::#{resource_name}.#{cm} is not defined"
            end
          end

          if (im = sdk["resource_instance_method"])
            unless resource_class.public_method_defined?(im)
              errors << "#{route_key}: Forem::#{resource_name}##{im} is not defined"
            end
          end
        else
          errors << "#{route_key}: Forem::#{resource_name} constant is not defined"
        end
      end

      if sdk["service_method"].nil? && sdk["resource_class_method"].nil? && sdk["resource_instance_method"].nil?
        errors << "#{route_key}: `sdk` mapping must specify at least one of service_method, resource_class_method, or resource_instance_method"
      end

      errors
    end

    # Returns a summary of all Client accessors and their public service methods.
    def client_surface
      client = Forem::Client.new("introspection-dummy-key")
      accessors = (Forem::Client.public_instance_methods(false) - %i[config requestor]).sort
      accessors.each_with_object({}) do |accessor, out|
        service = client.public_send(accessor)
        methods = service.class.public_instance_methods(false).map(&:to_s).sort
        out[accessor.to_s] = {
          "service_class" => service.class.name,
          "methods" => methods
        }
      end
    end
  end
end

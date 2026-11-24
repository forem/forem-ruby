module Forem
  # Represents metadata about the target Forem instance.
  #
  # Sends a GET request to the singular +/api/instance+ endpoint.
  #
  # == Instance Fields
  #
  # - +context+ (String)
  # - +cover_image_url+ (String)
  # - +description+ (String)
  # - +display_in_directory+ (Boolean)
  # - +domain+ (String)
  # - +logo_image_url+ (String)
  # - +name+ (String)
  # - +tagline+ (String)
  # - +version+ (String)
  # - +visibility+ (String) — +"public"+, +"private"+, or +"pending"+
  #
  # @example Retrieve Forem instance details
  #   info = client.instance.retrieve
  #   puts "#{info.name} (#{info.domain}) v#{info.version}"
  #
  # @see https://developers.forem.com/api/v1
  class Instance < APIResource
    OBJECT_NAME = "instance"
    RESOURCE_PATH = "/api/instance"

    # Retrieve metadata for the Forem instance.
    #
    # Sends a GET request to +/api/instance+.
    #
    # @param opts [Hash] per-request options (e.g., +:api_key+)
    # @return [Forem::Instance] instance metadata object
    def self.retrieve(opts = {})
      requestor = opts[:requestor]
      resp = request(:get, resource_path, {}, opts)
      construct_from(resp.parsed_body, requestor: requestor)
    end
  end
end

module Forem
  # Base class for all Forem API resource objects (articles, users, etc.).
  #
  # {APIResource} extends {ForemObject} with the concepts of a canonical
  # resource path and the ability to refresh an instance from the API.
  # Concrete resource classes must define a +RESOURCE_PATH+ constant
  # (e.g. <tt>"/api/articles"</tt>).
  #
  # Resource classes mix in {APIOperations::Request} so that both the class
  # and its instances can issue authenticated HTTP requests. Class methods
  # require an explicit +:requestor+ option (normally injected by a
  # {Forem::Client} via its service objects); instance methods fall back to
  # the requestor stored on the object at construction time.
  #
  # @example Defining a resource subclass
  #   class Forem::Article < Forem::APIResource
  #     RESOURCE_PATH = "/api/articles"
  #     extend APIOperations::List
  #     extend APIOperations::Retrieve
  #   end
  class APIResource < ForemObject
    # Return the API collection path for this resource class.
    #
    # Delegates to the +RESOURCE_PATH+ constant that every concrete subclass
    # must define.
    #
    # @return [String] the collection path, e.g. <tt>"/api/articles"</tt>.
    # @raise [NameError] if the subclass has not defined +RESOURCE_PATH+.
    #
    # @example
    #   Forem::Article.resource_path  #=> "/api/articles"
    def self.resource_path
      self::RESOURCE_PATH
    end

    # Return the API path for this specific resource instance.
    #
    # Combines {.resource_path} with the instance's +id+ attribute.
    #
    # @return [String] the instance path, e.g. <tt>"/api/articles/42"</tt>.
    # @raise [InvalidRequestError] if the instance does not have an +id+
    #   attribute (i.e. the object was not constructed from a full API
    #   response).
    #
    # @example
    #   article.resource_url  #=> "/api/articles/42"
    def resource_url
      id = self["id"]
      raise InvalidRequestError.new("Could not determine resource ID") unless id
      "#{self.class.resource_path}/#{id}"
    end

    # Reload this resource instance from the API, replacing all attributes
    # with the latest server data.
    #
    # @param opts [Hash] per-request options forwarded to {APIRequestor#request}.
    # @option opts [String] :api_key override the API key for this request.
    # @option opts [APIRequestor] :requestor a custom requestor to use.
    # @return [self] the same instance, now populated with refreshed data.
    # @raise [InvalidRequestError] if the instance has no +id+.
    # @raise [NotFoundError] if the resource no longer exists on the server.
    # @raise [ForemError] for other API-level errors.
    #
    # @example
    #   article = client.articles.retrieve(42)
    #   # ... time passes ...
    #   article.refresh   #=> same article object with updated attributes
    #
    # @see https://developers.forem.com/api/v1
    def refresh(opts = {})
      resp = request(:get, resource_url, {}, opts)
      @values = {}
      send(:update_attributes, resp.parsed_body)
      self
    end
  end
end

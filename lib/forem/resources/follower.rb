module Forem
  class Follower < APIResource
    OBJECT_NAME = "follower"
    RESOURCE_PATH = "/api/followers"

    def self.list(params = {}, opts = {})
      requestor = opts[:requestor]
      resp = request(:get, "/api/followers/users", params, opts)
      data = (resp.parsed_body || []).map { |item| construct_from(item) }
      per_page = params[:per_page] || params["per_page"] || 80
      page = params[:page] || params["page"] || 1
      ListObject.new(
        data: data, current_page: page.to_i, per_page: per_page.to_i,
        resource_class: self,
        filters: params.reject { |k, _| [:page, :per_page, "page", "per_page"].include?(k) },
        requestor: requestor
      )
    end
  end
end

module Forem
  class Follow < APIResource
    OBJECT_NAME = "follow"
    RESOURCE_PATH = "/api/follows"

    def self.list(params = {}, opts = {})
      requestor = opts[:requestor]
      resp = request(:get, "/api/follows/tags", params, opts)
      data = (resp.parsed_body || []).map { |item| construct_from(item) }
      per_page = params[:per_page] || params["per_page"] || 30
      page = params[:page] || params["page"] || 1
      ListObject.new(
        data: data, current_page: page.to_i, per_page: per_page.to_i,
        resource_class: self,
        filters: params.reject { |k, _| [:page, :per_page, "page", "per_page"].include?(k) },
        requestor: requestor
      )
    end

    def self.create(params = {}, opts = {})
      resp = request(:post, resource_path, params, opts)
      construct_from(resp.parsed_body)
    end
  end
end

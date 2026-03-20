module Forem
  module APIOperations
    module List
      def list(params = {}, opts = {})
        requestor = opts[:requestor]
        resp = request(:get, resource_path, params, opts)
        data = (resp.parsed_body || []).map { |item| construct_from(item) }
        per_page = params[:per_page] || params["per_page"] || 30
        page = params[:page] || params["page"] || 1

        ListObject.new(
          data: data,
          current_page: page.to_i,
          per_page: per_page.to_i,
          resource_class: self,
          filters: params.reject { |k, _| [:page, :per_page, "page", "per_page"].include?(k) },
          requestor: requestor
        )
      end
    end
  end
end

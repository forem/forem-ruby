module Forem
  module Services
    # Service for interacting with the Forem Subforems API.
    #
    # Access via {Client#subforems}.
    #
    # @see Subforem
    # @see https://developers.forem.com/api/v1
    class SubforemService < BaseService
      # List discoverable and root subforems.
      #
      # @param params [Hash] query parameters
      # @param opts [Hash] per-request options
      # @return [ListObject<Subforem>] list of subforems
      def list(params = {}, opts = {})
        Subforem.list(params, opts_with_requestor(opts))
      end
    end
  end
end

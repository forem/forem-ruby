module Forem
  module Services
    # Service for retrieving metadata about the Forem instance.
    #
    # Access via {Client#instance}.
    #
    # @see Instance
    # @see https://developers.forem.com/api/v1
    class InstanceService < BaseService
      # Retrieve metadata about the Forem instance (+GET /api/instance+).
      #
      # @param opts [Hash] per-request options
      # @return [Instance] instance metadata
      def retrieve(opts = {})
        Instance.retrieve(opts_with_requestor(opts))
      end
    end
  end
end

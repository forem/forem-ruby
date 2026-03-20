module Forem
  module Services
    class ReactionService < BaseService
      def create(params = {}, opts = {})
        Reaction.create(params, opts_with_requestor(opts))
      end

      def toggle(params = {}, opts = {})
        Reaction.toggle(params, opts_with_requestor(opts))
      end
    end
  end
end

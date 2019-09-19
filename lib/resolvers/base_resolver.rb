# frozen_string_literal: true

module Facter
  module Resolvers
    class BaseResolver
      def self.invalidate_cache
        @fact_list = {}
      end

      def self.subscribe_to_manager
        Facter::ResolverManager.subscribe(self)
      end
    end
  end
end

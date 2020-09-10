# frozen_string_literal: true

module Facter
  module Resolvers
    class BaseResolver
      def self.log
        @log ||= Log.new(self)
      end

      def self.invalidate_cache
        @fact_list = {}
      end

      def self.subscribe_to_manager
        Facter::SessionCache.subscribe(self)
      end

      def self.resolve(fact_name)
        subscribe_to_manager
        post_resolve(fact_name)

        validate_resolution(fact_name)
      rescue LoadError, NameError => e
        log.debug("resolving fact #{fact_name}, but #{e}")
        @fact_list[fact_name] = nil
      end

      def self.validate_resolution(fact_name)
        @fact_list.fetch(fact_name) { @fact_list[fact_name] = nil }
        @fact_list[fact_name]
      end

      def self.post_resolve(_fact_name)
        raise NotImplementedError, "You must implement post_resolve(fact_name) method in #{name}"
      end
    end
  end
end

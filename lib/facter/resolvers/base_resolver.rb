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

      def self.init_resolver
        @fact_list = {}
        @semaphore = Mutex.new
      end

      def self.subscribe_to_manager
        Facter::SessionCache.subscribe(self)
      end

      def self.resolve(fact_name, options = {})
        @semaphore.synchronize do
          subscribe_to_manager
          post_resolve(fact_name, options)

          cache_nil_for_unresolved_facts(fact_name)
        end
      rescue NoMethodError => e
        log.debug("Could not resolve #{fact_name}, got #{e} at #{e.backtrace[0]}")
        @fact_list[fact_name] = nil
      rescue LoadError, NameError => e
        log.debug("Resolving fact #{fact_name}, but got #{e} at #{e.backtrace[0]}")
        @fact_list[fact_name] = nil
      end

      def self.cache_nil_for_unresolved_facts(fact_name)
        @fact_list.fetch(fact_name) { @fact_list[fact_name] = nil }
        @fact_list[fact_name]
      end

      def self.post_resolve(_fact_name, _options)
        raise NotImplementedError, "You must implement post_resolve(fact_name, options) method in #{name}"
      end
    end
  end
end

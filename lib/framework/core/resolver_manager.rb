# frozen_string_literal: true

module Facter
  class ResolverManager
    @semaphore = Mutex.new
    @resolvers = []

    def self.subscribe(resolver)
      @semaphore.synchronize do
        @resolvers << resolver
      end
    end

    def self.invalidate_all_caches
      @resolvers.uniq.each(&:invalidate_cache)
      @resolvers = []
    end
  end
end

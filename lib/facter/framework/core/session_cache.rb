# frozen_string_literal: true

module Facter
  class SessionCache
    @resolvers = []

    def self.subscribe(resolver)
      @resolvers << resolver
    end

    def self.invalidate_all_caches
      @resolvers.uniq.each(&:invalidate_cache)
      @resolvers = []
    end
  end
end

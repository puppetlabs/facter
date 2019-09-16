# frozen_string_literal: true

module Facter
  module Resolver
    class BaseResolver
      def self.invalidate_cache
        @fact_list = {}
      end
    end
  end
end

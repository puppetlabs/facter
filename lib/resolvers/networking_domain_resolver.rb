# frozen_string_literal: true

module Facter
  module Resolvers
    class NetworkingDomain < BaseResolver
      # :networking_domain

      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_networking_domain(fact_name) }
        end

        def read_networking_domain(fact_name)
          output = File.read('/etc/resolv.conf')
          output.match(/^search\s+(\S+)/)
          @fact_list[:networking_domain] = Regexp.last_match(1)
          @fact_list[fact_name]
        end
      end
    end
  end
end

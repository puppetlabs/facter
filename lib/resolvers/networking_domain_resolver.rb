# frozen_string_literal: true

module Facter
  module Resolvers
    class NetworkingDomain < BaseResolver
      # :networking_domain

      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || read_networking_domain(fact_name)
          end
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

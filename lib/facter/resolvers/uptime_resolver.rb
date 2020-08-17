# frozen_string_literal: true

module Facter
  module Resolvers
    class Uptime < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { uptime_system_call(fact_name) }
        end

        def uptime_system_call(fact_name)
          seconds = Facter::UptimeParser.uptime_seconds_unix
          build_fact_list(seconds)

          @fact_list[fact_name]
        end

        def build_fact_list(seconds)
          return @fact_list[:uptime] = 'unknown' unless seconds

          @fact_list = Utils::UptimeHelper.create_uptime_hash(seconds)
        end
      end
    end
  end
end

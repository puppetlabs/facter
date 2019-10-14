# frozen_string_literal: true

module Facter
  module Resolvers
    class Uptime < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || uptime_system_call(fact_name)
          end
        end

        private

        def uptime_system_call(fact_name)
          seconds = Facter::UptimeParser.uptime_seconds_unix
          build_fact_list(seconds)

          @fact_list[fact_name]
        end

        def build_fact_list(seconds)
          return @fact_list[:uptime] = 'unknown' unless seconds

          uptime_hash = create_uptime_hash(seconds)

          @fact_list[:seconds] = uptime_hash[:seconds]
          @fact_list[:hours]   = uptime_hash[:hours]
          @fact_list[:days]    = uptime_hash[:days]
          @fact_list[:uptime]  = uptime_hash[:uptime]
        end

        def create_uptime_hash(seconds)
          results = {}
          minutes = (seconds / 60) % 60

          results[:seconds] = seconds
          results[:hours]   = seconds / (60 * 60)
          results[:days]    = results[:hours] / 24
          results[:uptime]  = build_uptime_text(results[:days], results[:hours], minutes)

          results
        end

        def build_uptime_text(days, hours, minutes)
          case days
          when 0 then "#{hours}:#{format('%02d', minutes)} hours"
          when 1 then '1 day'
          else
            "#{days} days"
          end
        end
      end
    end
  end
end

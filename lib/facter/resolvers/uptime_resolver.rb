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
          when 0 then "#{hours}:#{format('%<minutes>02d', minutes: minutes)} hours"
          when 1 then '1 day'
          else
            "#{days} days"
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Facter
  module Resolvers
    module Utils
      module UptimeHelper
        class << self
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
end

# frozen_string_literal: true

require 'date'

module Facter
  module Resolvers
    module Windows
      class Uptime < BaseResolver
        @log = Facter::Log.new(self)

        init_resolver

        class << self
          private

          def post_resolve(fact_name, _options)
            @fact_list.fetch(fact_name) { calculate_system_uptime(fact_name) }
          end

          def subtract_system_uptime_from_ole
            win = Facter::Util::Windows::Win32Ole.new
            opsystem = win.return_first('SELECT LocalDateTime,LastBootUpTime FROM Win32_OperatingSystem')
            unless opsystem
              @log.debug 'WMI query returned no results'\
          'for Win32_OperatingSystem with values LocalDateTime and LastBootUpTime.'
              return
            end

            local_time = opsystem.LocalDateTime
            last_bootup = opsystem.LastBootUpTime

            return DateTime.parse(local_time).to_time - DateTime.parse(last_bootup).to_time if local_time && last_bootup

            nil
          end

          def calculate_system_uptime(fact_name)
            seconds = subtract_system_uptime_from_ole&.to_i
            if !seconds || seconds.negative?
              @log.debug 'Unable to determine system uptime!'
              return
            end

            @fact_list = Facter::Util::Resolvers::UptimeHelper.create_uptime_hash(seconds)
            @fact_list[fact_name]
          end

          def build_fact_list(system_uptime)
            @fact_list[:days] = system_uptime[:days]
            @fact_list[:hours] = system_uptime[:hours]
            @fact_list[:seconds] = system_uptime[:seconds]
            @fact_list[:uptime] = system_uptime[:uptime]
          end
        end
      end
    end
  end
end

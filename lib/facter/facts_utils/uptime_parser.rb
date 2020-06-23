# frozen_string_literal: true

require 'time'

module Facter
  class UptimeParser
    SECS_IN_A_DAY = 86_400
    SECS_IN_AN_HOUR = 3_600
    SECS_IN_A_MINUTE = 60

    @log = Facter::Log.new(self)

    class << self
      def uptime_seconds_unix
        uptime_proc_uptime || uptime_sysctl || uptime_executable
      end

      private

      def uptime_proc_uptime
        output = Facter::Core::Execution.execute("/bin/cat #{uptime_file}", logger: @log)

        output.chomp.split(' ').first.to_i unless output.empty?
      end

      def uptime_sysctl
        output = Facter::Core::Execution.execute("sysctl -n #{uptime_sysctl_variable}", logger: @log)

        compute_uptime(Time.at(output.match(/\d+/)[0].to_i)) unless output.empty?
      end

      def uptime_executable
        output = Facter::Core::Execution.execute(uptime_executable_cmd, logger: @log)

        return unless output

        up = 0
        output_calculator_methods.find { |method| up = send(method, output) }
        up || 0
      end

      def uptime_file
        '/proc/uptime'
      end

      def uptime_sysctl_variable
        'kern.boottime'
      end

      def uptime_executable_cmd
        'uptime'
      end

      def output_calculator_methods
        %i[
          calculate_days_hours_minutes
          calculate_days_hours
          calculate_days_minutes
          calculate_days
          calculate_hours_minutes
          calculate_hours
          calculate_minutes
        ]
      end

      def compute_uptime(time)
        (Time.now - time).to_i
      end

      # Regexp handles Solaris, AIX, HP-UX, and Tru64.
      # 'day(?:s|\(s\))?' says maybe 'day', 'days',
      #   or 'day(s)', and don't set $2.
      def calculate_days_hours_minutes(output)
        return unless output =~ /(\d+) day(?:s|\(s\))?,?\s+(\d+):-?(\d+)/

        SECS_IN_A_DAY * Regexp.last_match(1).to_i +
          SECS_IN_AN_HOUR * Regexp.last_match(2).to_i +
          SECS_IN_A_MINUTE * Regexp.last_match(3).to_i
      end

      def calculate_days_hours(output)
        return unless output =~ /(\d+) day(?:s|\(s\))?,\s+(\d+) hr(?:s|\(s\))?,/

        SECS_IN_A_DAY * Regexp.last_match(1).to_i +
          SECS_IN_AN_HOUR * Regexp.last_match(2).to_i
      end

      def calculate_days_minutes(output)
        return unless output =~ /(\d+) day(?:s|\(s\))?,\s+(\d+) min(?:s|\(s\))?,/

        SECS_IN_A_DAY * Regexp.last_match(1).to_i +
          SECS_IN_A_MINUTE * Regexp.last_match(2).to_i
      end

      def calculate_days(output)
        return unless output =~ /(\d+) day(?:s|\(s\))?,/

        SECS_IN_A_DAY * Regexp.last_match(1).to_i
      end

      # must anchor to 'up' to avoid matching time of day
      # at beginning of line. Certain versions of uptime on
      # Solaris may insert a '-' into the minutes field.
      def calculate_hours_minutes(output)
        return unless output =~ /up\s+(\d+):-?(\d+),/

        SECS_IN_AN_HOUR * Regexp.last_match(1).to_i +
          SECS_IN_A_MINUTE * Regexp.last_match(2).to_i
      end

      def calculate_hours(output)
        return unless output =~ /(\d+) hr(?:s|\(s\))?,/

        SECS_IN_AN_HOUR * Regexp.last_match(1).to_i
      end

      def calculate_minutes(output)
        return unless output =~ /(\d+) min(?:s|\(s\))?,/

        SECS_IN_A_MINUTE * Regexp.last_match(1).to_i
      end
    end
  end
end

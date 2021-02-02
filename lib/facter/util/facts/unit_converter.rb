# frozen_string_literal: true

module Facter
  module Util
    module Facts
      class UnitConverter
        class << self
          def bytes_to_mb(value_in_bytes)
            return unless value_in_bytes

            value_in_bytes = value_in_bytes.to_i

            (value_in_bytes / (1024.0 * 1024.0)).round(2)
          end

          def hertz_to_human_readable(speed)
            speed = speed.to_i
            return if !speed || speed.zero?

            validated_speed, metric_prefix = determine_metric_prefix(speed)

            format('%<displayed_speed>.2f', displayed_speed: validated_speed).to_s + ' ' + metric_prefix + 'Hz'
          end

          def bytes_to_human_readable(bytes)
            return unless bytes
            return bytes.to_s + ' bytes' if bytes < 1024

            number, multiple = determine_exponent(bytes)

            "#{pad_number(number)} #{multiple}"
          end

          private

          def pad_number(number)
            number = number.to_s
            number << '0' if number.split('.').last.length == 1
            number
          end

          def determine_exponent(bytes)
            prefix = %w[KiB MiB GiB TiB PiB EiB]
            exp = (Math.log2(bytes) / 10.0).floor
            converted_number = (100.0 * (bytes / 1024.0**exp)).round / 100.0

            if (converted_number - 1024.0).abs < Float::EPSILON
              exp += 1
              converted_number = 1.00
            end
            multiple = prefix[exp - 1] || 'bytes'

            converted_number = bytes if multiple == 'bytes'
            [converted_number, multiple]
          end

          def determine_metric_prefix(num)
            metric_prefix = { 0 => '', 3 => 'k', 6 => 'M', 9 => 'G', 12 => 'T' }
            power = Math.log10(num).floor
            display_exponent = power - power % 3
            coefficient = power.zero? ? num.to_f : num.fdiv(10**display_exponent)
            [coefficient, metric_prefix[display_exponent]]
          end
        end
      end
    end
  end
end

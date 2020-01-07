# frozen_string_literal: true

module Facter
  class BytesToHumanReadable
    class << self
      def convert(bytes)
        return unless bytes
        return bytes.to_s + ' bytes' if bytes < 1024

        units = %w[K M G T P E]
        result = determine_exponent(bytes)
        return bytes.to_s + ' bytes' if result[:exp] > units.size

        converted_number = pad_number(result[:converted_number])
        converted_number + " #{units[result[:exp] - 1]}iB"
      end

      private

      def pad_number(number)
        number = number.to_s
        number << '0' if number.split('.').last.length == 1
        number
      end

      def determine_exponent(bytes)
        exp = (Math.log2(bytes) / 10.0).floor
        converted_number = (100.0 * (bytes / 1024.0**exp)).round / 100.0

        if (converted_number - 1024.0).abs < Float::EPSILON
          exp += 1
          converted_number = 1.00
        end
        { exp: exp, converted_number: converted_number }
      end
    end
  end
end

# frozen_string_literal: true

# A restricting tag for fact resolution mechanisms.  The tag must be true
# for the resolution mechanism to be suitable.

module LegacyFacter
  module Util
    class Confine
      attr_accessor :fact, :values

      include LegacyFacter::Util::Values

      # Add the restriction.  Requires the fact name, an operator, and the value
      # we're comparing to.
      #
      # @param fact [Symbol] Name of the fact
      # @param values [Array] One or more values to match against.
      #   They can be any type that provides a === method.
      # @param block [Proc] Alternatively a block can be supplied as a check.  The fact
      #   value will be passed as the argument to the block.  If the block returns
      #   true then the fact will be enabled, otherwise it will be disabled.
      def initialize(fact = nil, *values, &block)
        raise ArgumentError, 'The fact name must be provided' unless fact || block_given?
        raise ArgumentError, 'One or more values or a block must be provided' if values.empty? && !block_given?

        @fact = fact
        @values = values
        @block = block
      end

      def to_s
        return @block.to_s if @block

        format("'%<fact>s' '%<values>s'", fact: @fact, values: @values.join(','))
      end

      # Evaluate the fact, returning true or false.
      # if we have a block paramter then we only evaluate that instead
      def true?
        if @block && !@fact
          begin
            return !!@block.call
          rescue StandardError => e
            LegacyFacter.debug "Confine raised #{e.class} #{e}"
            return false
          end
        end

        unless (fact = LegacyFacter[@fact])
          LegacyFacter.debug format('No fact for %<fact>s', fact: @fact)
          return false
        end
        value = convert(fact.value)

        return false if value.nil?

        if @block
          begin
            return !!@block.call(value)
          rescue StandardError => e
            LegacyFacter.debug "Confine raised #{e.class} #{e}"
            return false
          end
        end

        @values.any? { |v| convert(v) === value }
      end
    end
  end
end

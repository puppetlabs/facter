# A restricting tag for fact resolution mechanisms.  The tag must be true
# for the resolution mechanism to be suitable.

require 'facter/util/values'

class Facter::Util::Confine
  attr_accessor :fact, :values

  include Facter::Util::Values

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
    raise ArgumentError, "The fact name must be provided" unless fact or block_given?
    if values.empty? and not block_given?
      raise ArgumentError, "One or more values or a block must be provided"
    end
    @fact = fact
    @values = values
    @block = block
  end

  def to_s
    return @block.to_s if @block
    return "'%s' '%s'" % [@fact, @values.join(",")]
  end

  # Evaluate the fact, returning true or false.
  # if we have a block paramter then we only evaluate that instead
  def true?
    if @block and not @fact then
      begin
        return !! @block.call
      rescue StandardError => error
        Facter.debug "Confine raised #{error.class} #{error}"
        return false
      end
    end

    unless fact = Facter[@fact]
      Facter.debug "No fact for %s" % @fact
      return false
    end
    value = convert(fact.value)

    return false if value.nil?

    if @block then
      begin
        return !! @block.call(value)
      rescue StandardError => error
        Facter.debug "Confine raised #{error.class} #{error}"
        return false
      end
    end

    return @values.any? do |v| convert(v) === value end
  end
end

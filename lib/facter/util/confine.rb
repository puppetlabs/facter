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
  #   They can be any type that provides a === method. Proc types will be
  #   evaluated by using the call method with the value of the fact as parameter.
  # @param block Alternatively a block can be supplied as a check
  def initialize(fact = nil, *values, &block)
    if block_given? then
      @block = block
    else
      raise ArgumentError, "The fact name must be provided" unless fact
      raise ArgumentError, "One or more values or a block must be provided" if values.empty?
      @fact = fact
      @values = values
    end
  end

  def to_s
    return @block.to_s if @block
    return "'%s' '%s'" % [@fact, @values.join(",")]
  end

  # Evaluate the fact, returning true or false.
  # if we have a block paramter then we only evaluate that instead
  def true?
    if @block then
      begin
        return @block.call
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

    return @values.any? do |v|
      # Always use Ruby 1.9+ semantics on Proc confines.
      if v.kind_of? Proc then
        begin
          v.call(value)
        rescue StandardError => error
          Facter.debug "Confine raised #{error.class} #{error}"
          false
        end
      else
        convert(v) === value
      end
    end
  end
end

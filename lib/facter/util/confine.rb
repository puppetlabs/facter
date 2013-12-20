# A restricting tag for fact resolution mechanisms.  The tag must be true
# for the resolution mechanism to be suitable.

require 'facter/util/values'

class Facter::Util::Confine
  require 'facter/util/name'

  include Facter::Util::Name
  include Facter::Util::Values

  attr_accessor :fact, :values

  # Add the restriction.  Requires the fact name, an operator, and the value
  # we're comparing to.
  def initialize(fact, *values)
    fact = canonicalize_name(fact)

    raise ArgumentError, "The fact name must be provided" unless fact
    raise ArgumentError, "One or more values must be provided" if values.empty?
    @fact = fact
    @values = values
  end

  def to_s
    return "'%s' '%s'" % [@fact, @values.join(",")]
  end

  # Evaluate the fact, returning true or false.
  def true?
    unless fact = Facter[@fact]
      Facter.debug "No fact for %s" % @fact
      return false
    end
    value = convert(fact.value)

    return false if value.nil?

    return @values.any? { |v| convert(v) === value }
  end
end

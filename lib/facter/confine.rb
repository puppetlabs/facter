# A restricting tag for fact resolution mechanisms.  The tag must be true
# for the resolution mechanism to be suitable.
class Facter::Confine
    attr_accessor :fact, :values

    # Add the restriction.  Requires the fact name, an operator, and the value
    # we're comparing to.
    def initialize(fact, *values)
        raise ArgumentError, "The fact name must be provided" unless fact
        raise ArgumentError, "One or more values must be provided" if values.empty?
        fact = fact.to_s if fact.is_a? Symbol
        @fact = fact
        @values = values.collect do |value|
            if value.is_a? String
                value
            else
                value.to_s
            end
        end
    end

    def to_s
        return "'%s' '%s'" % [@fact, @values.join(",")]
    end

    # Evaluate the fact, returning true or false.
    def true?
        fact = nil
        unless fact = Facter[@fact]
            Facter.debug "No fact for %s" % @fact
            return false
        end
        value = fact.value

        if value.nil?
            return false
        end

        retval = @values.find { |v|
            if value.downcase == v.downcase
                break true
            end
        }

        if retval
            retval = true
        else
            retval = false
        end

        return retval || false
    end
end

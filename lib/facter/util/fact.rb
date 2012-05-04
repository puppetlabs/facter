require 'facter'
require 'facter/util/resolution'

class Facter::Util::Fact
  TIMEOUT = 5

  attr_accessor :name, :ldapname

  # Create a new fact, with no resolution mechanisms.
  def initialize(name, options = {})
    @name = name.to_s.downcase.intern

    # LAK:NOTE: This is slow for many options, but generally we won't have any and at
    # worst we'll have one.  If we add more, this should be made more efficient.
    options.each do |name, value|
      case name
      when :ldapname; self.ldapname = value
      else
        raise ArgumentError, "Invalid fact option '%s'" % name
      end
    end

    @ldapname ||= @name.to_s

    @resolves = []
    @searching = false

    @value = nil
  end

  # Add a new resolution mechanism.  This requires a block, which will then
  # be evaluated in the context of the new mechanism.
  def add(value = nil, &block)
    begin
      resolve = Facter::Util::Resolution.new(@name)

      resolve.instance_eval(&block) if block
      @resolves << resolve

      # Immediately sort the resolutions, so that we always have
      # a sorted list for looking up values.
      @resolves.sort! { |a, b| b.weight <=> a.weight }

      resolve
    rescue => e
      Facter.warn "Unable to add resolve for #{@name}: #{e}"
      nil
    end
  end

  # Flush any cached values.
  def flush
    @value = nil
    @suitable = nil
  end

  # Return the value for a given fact.  Searches through all of the mechanisms
  # and returns either the first value or nil.
  def value
    return @value if @value

    suitable_resolves = @resolves.select {|r| r.suitable? }

    if suitable_resolves.length == 0
      Facter.debug "Found no suitable resolves of %s for %s" %
        [@resolves.length, @name]
      return nil
    else
      searching do
        suitable_resolves.each do |resolve|
          val = resolve.value
          if val.nil?
            next
          elsif valid? val
            @value = val
            break
          else
            Facter.warnonce("Resolution returned invalid data for fact '#{@name}'")
            Facter.debug("Resolution returned the following invalid data " +
              "for fact '#{@name}':\n  #{val.inspect}")
          end
        end
      end
    end

    if @value.nil?
      Facter.debug("Could not resolve fact #{@name}")
    end

    @value
  end

  private

  # Validate that an object is either a string, hash, array or
  # combination thereof.
  def valid?(value)
    case value
    when String,TrueClass,FalseClass,Numeric then
      return true
    when Array then
      validity = true
      # Validate each item by calling validate again
      value.each do |item|
        if (validity = valid?(item)) == false
          break
        end
      end
      return validity
    when Hash then
      validity = true
      value.each do |k,v|
        # Validate key first
        if (validity = validate_value_lhs(k)) == false
          break
        end

        # Validate value by calling validate again
        if (validity = valid?(v)) == false
          break
        end
      end
      return validity
    else
      return false
    end
  end

  # This method is used for validating the left hand side in
  # a hash.
  def validate_value_lhs(value)
    case value
    when String
      if value.empty?
        return false
      else
        return true
      end
    else
      return false
    end
  end

  # Are we in the midst of a search?
  def searching?
    @searching
  end

  # Lock our searching process, so we never ge stuck in recursion.
  def searching
    if searching?
      Facter.debug "Caught recursion on %s" % @name

      # return a cached value if we've got it
      if @value
        return @value
      else
        return nil
      end
    end

    # If we've gotten this far, we're not already searching, so go ahead and do so.
    @searching = true
    begin
      yield
    ensure
      @searching = false
    end
  end
end

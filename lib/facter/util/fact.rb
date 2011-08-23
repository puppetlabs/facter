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
      Facter.debug "Found no suitable resolves of %s for %s" % [@resolves.length, @name]
      return nil
    else
      searching do
        suitable_resolves.each do |resolve|
          val = resolve.value
          if valid? val
            @value = val
            break
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

  def valid? entity
    validity = nil
    begin
      validity = case entity
      when NilClass
        false
      when String
        # Allow non-empty strings
        !entity.empty?
      when TrueClass, FalseClass, Numeric, Symbol
        # Permit all booleans, numbers, and symbols
        true
      when Array
        # If given an array, look for any valid elements
        entity.any? {|v| valid? v}
      when Hash
        # If given a hash, look for any valid values
        entity.values.any? {|v| valid? v}
      else
        false
      end
    rescue
      Facter.debug("Unable to validate value #{entity} for fact #{@name}")
      validity = false
    end
    validity
  end

  # Are we in the midst of a search?
  def searching?
    @searching
  end

  # Lock our searching process, so we never ge stuck in recursion.
  def searching
    raise RuntimeError, "Caught recursion on #{@name}" if searching?

    # If we've gotten this far, we're not already searching, so go ahead and do so.
    @searching = true
    begin
      yield
    ensure
      @searching = false
    end
  end
end

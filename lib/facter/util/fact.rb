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

      resolve
    rescue => e
      Facter.warn "Unable to add resolve for #{@name}: #{e}"
      nil
    end
  end

  ##
  # Flush any cached values.  If the resolver has a callback block defined
  # using the on_flush DSL method, then invoke that block by sending a message
  # to Resolution#flush.
  def flush
    @resolves.each { |r| r.flush }
    @value = nil
  end

  # Return the value for a given fact.  Searches through all of the mechanisms
  # and returns either the first value or nil.
  def value
    return @value if @value

    if @resolves.empty?
      Facter.debug "No resolves for %s" % @name
      return nil
    end

    searching do

      suitable_resolutions = sort_by_weight(find_suitable_resolutions(@resolves))
      @value = find_first_real_value(suitable_resolutions)

      announce_when_no_suitable_resolution(suitable_resolutions)
      announce_when_no_value_found(@value)

      @value
    end
  end


  private

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

  def find_suitable_resolutions(resolutions)
    resolutions.find_all{ |resolve| resolve.suitable? }
  end

  def sort_by_weight(resolutions)
    resolutions.sort { |a, b| b.weight <=> a.weight }
  end

  def find_first_real_value(resolutions)
    resolutions.each do |resolve|
      value = normalize_value(resolve.value)
      if not value.nil?
        return value
      end
    end
    nil
  end

  def announce_when_no_suitable_resolution(resolutions)
    if resolutions.empty?
      Facter.debug "Found no suitable resolves of %s for %s" % [@resolves.length, @name]
    end
  end

  def announce_when_no_value_found(value)
    if value.nil?
      Facter.debug("value for %s is still nil" % @name)
    end
  end

  def normalize_value(value)
    value == "" ? nil : value
  end
end

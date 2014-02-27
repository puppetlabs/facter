require 'facter'
require 'facter/util/resolution'
require 'facter/core/aggregate'

# This class represents a fact. Each fact has a name and multiple
# {Facter::Util::Resolution resolutions}.
#
# Create facts using {Facter.add}
#
# @api public
class Facter::Util::Fact
  # The name of the fact
  # @return [String]
  attr_accessor :name

  # @return [String]
  # @deprecated
  attr_accessor :ldapname

  # Creates a new fact, with no resolution mechanisms. See {Facter.add}
  # for the public API for creating facts.
  # @param name [String] the fact name
  # @param options [Hash] optional parameters
  # @option options [String] :ldapname set the ldapname property on the fact
  #
  # @api private
  def initialize(name, options = {})
    @name = name.to_s.downcase.intern

    extract_ldapname_option!(options)

    @ldapname ||= @name.to_s

    @resolves = []
    @searching = false

    @value = nil
  end

  # Adds a new {Facter::Util::Resolution resolution}.  This requires a
  # block, which will then be evaluated in the context of the new
  # resolution.
  #
  # @param options [Hash] A hash of options to set on the resolution
  #
  # @return [Facter::Util::Resolution]
  #
  # @api private
  def add(options = {}, &block)
    define_resolution(nil, options, &block)
  end

  # Define a new named resolution or return an existing resolution with
  # the given name.
  #
  # @param resolution_name [String] The name of the resolve to define or look up
  # @param options [Hash] A hash of options to set on the resolution
  # @return [Facter::Util::Resolution]
  #
  # @api public
  def define_resolution(resolution_name, options = {}, &block)

    resolution_type = options.delete(:type) || :simple

    resolve = create_or_return_resolution(resolution_name, resolution_type)

    resolve.set_options(options) unless options.empty?
    resolve.evaluate(&block) if block

    resolve
  rescue => e
    Facter.log_exception(e, "Unable to add resolve #{resolution_name.inspect} for fact #{@name}: #{e.message}")
  end

  # Retrieve an existing resolution by name
  #
  # @param name [String]
  #
  # @return [Facter::Util::Resolution, nil] The resolution if exists, nil if
  #   it doesn't exist or name is nil
  def resolution(name)
    return nil if name.nil?

    @resolves.find { |resolve| resolve.name == name }
  end

  # Flushes any cached values.
  #
  # @return [void]
  #
  # @api private
  def flush
    @resolves.each { |r| r.flush }
    @value = nil
  end

  # Returns the value for this fact. This searches all resolutions by
  # suitability and weight (see {Facter::Util::Resolution}). If no
  # suitable resolution is found, it returns nil.
  #
  # @api public
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

  # @api private
  # @deprecated
  def extract_ldapname_option!(options)
    if options[:ldapname]
      Facter.warnonce("ldapname is deprecated and will be removed in a future version")
      self.ldapname = options.delete(:ldapname)
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
      value = resolve.value
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

  def create_or_return_resolution(resolution_name, resolution_type)
    resolve = self.resolution(resolution_name)

    if resolve
      if resolution_type != resolve.resolution_type
        raise ArgumentError, "Cannot return resolution #{resolution_name} with type" +
          " #{resolution_type}; already defined as #{resolve.resolution_type}"
      end
    else
      case resolution_type
      when :simple
        resolve = Facter::Util::Resolution.new(resolution_name, self)
      when :aggregate
        resolve = Facter::Core::Aggregate.new(resolution_name, self)
      else
        raise ArgumentError, "Expected resolution type to be one of (:simple, :aggregate) but was #{resolution_type}"
      end

      @resolves << resolve
    end

    resolve
  end
end

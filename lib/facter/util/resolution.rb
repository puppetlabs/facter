require 'facter/util/confine'
require 'facter/util/config'
require 'facter/util/normalization'
require 'facter/core/execution'

require 'timeout'

# This represents a fact resolution. A resolution is a concrete
# implementation of a fact. A single fact can have many resolutions and
# the correct resolution will be chosen at runtime. Each time
# {Facter.add} is called, a new resolution is created and added to the
# set of resolutions for the fact named in the call.  Each resolution
# has a {#has_weight weight}, which defines its priority over other
# resolutions, and a set of {#confine _confinements_}, which defines the
# conditions under which it will be chosen. All confinements must be
# satisfied for a fact to be considered _suitable_.
#
# @api public
class Facter::Util::Resolution
  # The timeout, in seconds, for evaluating this resolution. The default
  # is 0 which is equivalent to no timeout. This can be set using the
  # options hash argument to {Facter.add}.
  # @return [Integer]
  # @api public
  attr_accessor :timeout

  # @!attribute [rw] name
  # The name of this resolution. The resolution name should be unique with
  # respect to the given fact.
  # @return [String]
  # @api public
  attr_accessor :name

  # @api private
  attr_accessor :code
  attr_writer :value, :weight

  INTERPRETER = Facter::Util::Config.is_windows? ? "cmd.exe" : "/bin/sh"

  extend Facter::Core::Execution

  class << self
    # Expose command execution methods that were extracted into
    # Facter::Util::Execution from Facter::Util::Resolution in Facter 2.0.0 for
    # compatibility.
    #
    # @deprecated
    public :search_paths, :which, :absolute_path?, :expand_command, :with_env, :exec
  end

  # Sets the conditions for this resolution to be used. This takes a
  # hash of fact names and values. Every fact must match the values
  # given for that fact, otherwise this resolution will not be
  # considered suitable. The values given for a fact can be an array, in
  # which case the value of the fact must be in the array for it to
  # match.
  #
  # @param confines [Hash{String => Object}] a hash of facts and the
  #   values they should have in order for this resolution to be
  #   used
  #
  # @example Confining to Linux
  #     Facter.add(:powerstates) do
  #       # This resolution only makes sense on linux systems
  #       confine :kernel => "Linux"
  #       setcode do
  #         Facter::Util::Resolution.exec('cat /sys/power/states')
  #       end
  #     end
  #
  # @return [void]
  #
  # @api public
  def confine(confines)
    confines.each do |fact, values|
      @confines.push Facter::Util::Confine.new(fact, *values)
    end
  end

  # Sets the weight of this resolution. If multiple suitable resolutions
  # are found, the one with the highest weight will be used.  If weight
  # is not given, the number of confines set on a resolution will be
  # used as its weight (so that the most specific resolution is used).
  #
  # @param weight [Integer] the weight of this resolution
  #
  # @return [void]
  #
  # @api public
  def has_weight(weight)
    @weight = weight
  end

  # Create a new resolution mechanism.
  #
  # @param name [String] The name of the resolution.
  # @return [void]
  #
  # @api private
  def initialize(name)
    @name = name
    @confines = []
    @value = nil
    @timeout = 0
    @weight = nil
  end

  def set_options(options)
    if options[:name]
      @name = options.delete(:name)
    end

    if options.has_key?(:value)
      @value = options.delete(:value)
    end

    if options.has_key?(:timeout)
      @timeout = options.delete(:timeout)
    end

    if options.has_key?(:weight)
      @weight = options.delete(:weight)
    end

    if not options.keys.empty?
      raise ArgumentError, "Invalid resolution options #{options.keys.inspect}"
    end
  end

  # Returns the importance of this resolution. If the weight was not
  # given, the number of confines is used instead (so that a more
  # specific resolution wins over a less specific one).
  #
  # @return [Integer] the weight of this resolution
  #
  # @api private
  def weight
    if @weight
      @weight
    else
      @confines.length
    end
  end

  # (see #timeout)
  # This is another name for {#timeout}.
  # @comment We need this as a getter for 'timeout', because some versions
  #   of ruby seem to already have a 'timeout' method and we can't
  #   seem to override the instance methods, somehow.
  def limit
    @timeout
  end

  # Sets the code block or external program that will be evaluated to
  # get the value of the fact.
  #
  # @return [void]
  #
  # @overload setcode(string)
  #   Sets an external program to call to get the value of the resolution
  #   @param [String] string the external program to run to get the
  #     value
  #
  # @overload setcode(&block)
  #   Sets the resolution's value by evaluating a block at runtime
  #   @param [Proc] block The block to determine the resolution's value.
  #     This block is run when the fact is evaluated. Errors raised from
  #     inside the block are rescued and printed to stderr.
  #
  # @api public
  def setcode(string = nil, interp = nil, &block)
    Facter.warnonce "The interpreter parameter to 'setcode' is deprecated and will be removed in a future version." if interp
    if string
      @code = string
      @interpreter = interp || INTERPRETER
    else
      unless block_given?
        raise ArgumentError, "You must pass either code or a block"
      end
      @code = block
    end
  end

  ##
  # on_flush accepts a block and executes the block when the resolution's value
  # is flushed.  This makes it possible to model a single, expensive system
  # call inside of a Ruby object and then define multiple dynamic facts which
  # resolve by sending messages to the model instance.  If one of the dynamic
  # facts is flushed then it can, in turn, flush the data stored in the model
  # instance to keep all of the dynamic facts in sync without making multiple,
  # expensive, system calls.
  #
  # Please see the Solaris zones fact for an example of how this feature may be
  # used.
  #
  # @see Facter::Util::Fact#flush
  # @see Facter::Util::Resolution#flush
  #
  # @api public
  def on_flush(&block)
    @on_flush_block = block
  end

  ##
  # flush executes the block, if any, stored by the {on_flush} method
  #
  # @see Facter::Util::Fact#flush
  # @see Facter::Util::Resolution#on_flush
  #
  # @api private
  def flush
    @on_flush_block.call if @on_flush_block
  end

  # @deprecated
  def interpreter
    Facter.warnonce "The 'Facter::Util::Resolution.interpreter' method is deprecated and will be removed in a future version."
    @interpreter
  end

  # @deprecated
  def interpreter=(interp)
    Facter.warnonce "The 'Facter::Util::Resolution.interpreter=' method is deprecated and will be removed in a future version."
    @interpreter = interp
  end

  # Is this resolution mechanism suitable on the system in question?
  #
  # @api private
  def suitable?
    if @suitable.nil?
      @suitable = @confines.all? { |confine| confine.true? }
    end

    return @suitable
  end

  # (see value)
  # @deprecated
  def to_s
    return self.value()
  end

  # Evaluates the code block or external program to get the value of the
  # fact.
  #
  # @api private
  def value
    return @value if @value
    result = nil
    return result if @code == nil

    starttime = Time.now.to_f

    begin
      Timeout.timeout(limit) do
        if @code.is_a?(Proc)
          result = @code.call()
        else
          result = Facter::Util::Resolution.exec(@code)
        end
      end
    rescue Timeout::Error => detail
      Facter.warn "Timed out seeking value for %s" % self.name

      # This call avoids zombies -- basically, create a thread that will
      # dezombify all of the child processes that we're ignoring because
      # of the timeout.
      Thread.new { Process.waitall }
      return nil
    rescue => details
      Facter.warn "Could not retrieve %s: %s" % [self.name, details]
      return nil
    end

    finishtime = Time.now.to_f
    ms = (finishtime - starttime) * 1000
    Facter.show_time "#{self.name}: #{"%.2f" % ms}ms"

    Facter::Util::Normalization.normalize(result)
  rescue Facter::Util::Normalization::NormalizationError => e
    Facter.warn "Fact resolution #{self.name} resolved to an invalid value: #{e.message}"
    nil
  end
end

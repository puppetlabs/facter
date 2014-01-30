require 'facter/util/confine'
require 'facter/util/config'
require 'facter/util/normalization'
require 'facter/core/execution'
require 'facter/core/resolvable'
require 'facter/core/suitable'

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
  # @api private
  attr_accessor :code
  attr_writer :value

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

  include Facter::Core::Resolvable
  include Facter::Core::Suitable

  # @!attribute [rw] name
  # The name of this resolution. The resolution name should be unique with
  # respect to the given fact.
  # @return [String]
  # @api public
  attr_accessor :name

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

  # (see value)
  # @deprecated
  def to_s
    return self.value()
  end

  private

  def resolve_value
    return @value if @value
    return nil if @code.nil?

    if @code.is_a? Proc
      @code.call()
    else
      Facter::Util::Resolution.exec(@code)
    end
  end
end

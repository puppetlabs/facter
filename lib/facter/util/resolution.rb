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

  extend Facter::Core::Execution

  class << self
    # Expose command execution methods that were extracted into
    # Facter::Core::Execution from Facter::Util::Resolution in Facter 2.0.0 for
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

  # @!attribute [r] fact
  # @return [Facter::Util::Fact]
  # @api private
  attr_reader :fact

  # Create a new resolution mechanism.
  #
  # @param name [String] The name of the resolution.
  # @return [void]
  #
  # @api private
  def initialize(name, fact)
    @name = name
    @fact = fact
    @confines = []
    @value = nil
    @timeout = 0
    @weight = nil
  end

  def resolution_type
    :simple
  end

  # Evaluate the given block in the context of this resolution. If a block has
  # already been evaluated emit a warning to that effect.
  #
  # @return [void]
  def evaluate(&block)
    if @last_evaluated
      msg = "Already evaluated #{@name}"
      msg << " at #{@last_evaluated}" if msg.is_a? String
      msg << ", reevaluating anyways"
      Facter.warn msg
    end

    instance_eval(&block)

    # Ruby 1.9+ provides the source location of procs which can provide useful
    # debugging information if a resolution is being evaluated twice. Since 1.8
    # doesn't support this we opportunistically provide this information.
    if block.respond_to? :source_location
      @last_evaluated = block.source_location.join(':')
    else
      @last_evaluated = true
    end
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
  def setcode(string = nil, &block)
    if string
      @code = Proc.new do
        output = Facter::Core::Execution.execute(string, :on_fail => nil)
        if output.nil? or output.empty?
          nil
        else
          output
        end
      end
    elsif block_given?
      @code = block
    else
      raise ArgumentError, "You must pass either code or a block"
    end
  end

  private

  def resolve_value
    if @value
      @value
    elsif @code.nil?
      nil
    elsif @code
      @code.call()
    end
  end
end

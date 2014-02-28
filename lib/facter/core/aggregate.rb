require 'facter'
require 'facter/core/directed_graph'
require 'facter/core/suitable'
require 'facter/core/resolvable'
require 'facter/util/values'

# Aggregates provide a mechanism for facts to be resolved in multiple steps.
#
# Aggregates are evaluated in two parts: generating individual chunks and then
# aggregating all chunks together. Each chunk is a block of code that generates
# a value, and may depend on other chunks when it runs. After all chunks have
# been evaluated they are passed to the aggregate block as Hash<name, result>.
# The aggregate block converts the individual chunks into a single value that is
# returned as the final value of the aggregate.
#
# @api public
# @since 2.0.0
class Facter::Core::Aggregate

  include Facter::Core::Suitable
  include Facter::Core::Resolvable

  # @!attribute [r] name
  #   @return [Symbol] The name of the aggregate resolution
  attr_reader :name

  # @!attribute [r] deps
  #   @api private
  #   @return [Facter::Core::DirectedGraph]
  attr_reader :deps

  # @!attribute [r] confines
  #   @return [Array<Facter::Core::Confine>] An array of confines restricting
  #     this to a specific platform
  #   @see Facter::Core::Suitable
  attr_reader :confines

  # @!attribute [r] fact
  # @return [Facter::Util::Fact]
  # @api private
  attr_reader :fact

  def initialize(name, fact)
    @name = name
    @fact = fact

    @confines = []
    @chunks = {}

    @aggregate = nil
    @deps = Facter::Core::DirectedGraph.new
  end

  def set_options(options)
    if options[:name]
      @name = options.delete(:name)
    end

    if options.has_key?(:timeout)
      @timeout = options.delete(:timeout)
    end

    if options.has_key?(:weight)
      @weight = options.delete(:weight)
    end

    if not options.keys.empty?
      raise ArgumentError, "Invalid aggregate options #{options.keys.inspect}"
    end
  end

  def evaluate(&block)
    instance_eval(&block)
  end

  # Define a new chunk for the given aggregate
  #
  # @api public
  #
  # @example Defining a chunk with no dependencies
  #   aggregate.chunk(:mountpoints) do
  #     # generate mountpoint information
  #   end
  #
  # @example Defining an chunk to add mount options
  #   aggregate.chunk(:mount_options, :require => [:mountpoints]) do |mountpoints|
  #     # `mountpoints` is the result of the previous chunk
  #     # generate mount option information based on the mountpoints
  #   end
  #
  # @param name [Symbol] A name unique to this aggregate describing the chunk
  # @param opts [Hash]
  # @options opts [Array<Symbol>, Symbol] :require One or more chunks
  #   to evaluate and pass to this block.
  # @yield [*Object] Zero or more chunk results
  #
  # @return [void]
  def chunk(name, opts = {}, &block)
    if not block_given?
      raise ArgumentError, "#{self.class.name}#chunk requires a block"
    end

    deps = Array(opts.delete(:require))

    if not opts.empty?
      raise ArgumentError, "Unexpected options passed to #{self.class.name}#chunk: #{opts.keys.inspect}"
    end

    @deps[name] = deps
    @chunks[name] = block
  end

  # Define how all chunks should be combined
  #
  # @api public
  #
  # @example Merge all chunks
  #   aggregate.aggregate do |chunks|
  #     final_result = {}
  #     chunks.each_value do |chunk|
  #       final_result.deep_merge(chunk)
  #     end
  #     final_result
  #   end
  #
  # @example Sum all chunks
  #   aggregate.aggregate do |chunks|
  #     total = 0
  #     chunks.each_value do |chunk|
  #       total += chunk
  #     end
  #     total
  #   end
  #
  # @yield [Hash<Symbol, Object>] A hash containing chunk names and
  #   chunk values
  #
  # @return [void]
  def aggregate(&block)
    if block_given?
      @aggregate = block
    else
      raise ArgumentError, "#{self.class.name}#aggregate requires a block"
    end
  end

  def resolution_type
    :aggregate
  end

  private

  # Evaluate the results of this aggregate.
  #
  # @see Facter::Core::Resolvable#value
  # @return [Object]
  def resolve_value
    chunk_results = run_chunks()
    aggregate_results(chunk_results)
  end

  # Order all chunks based on their dependencies and evaluate each one, passing
  # dependent chunks as needed.
  #
  # @return [Hash<Symbol, Object>] A hash containing the chunk that
  #   generated value and the related value.
  def run_chunks
    results = {}
    order_chunks.each do |(name, block)|
      input = @deps[name].map { |dep_name| results[dep_name] }

      output = block.call(*input)
      results[name] = Facter::Util::Values.deep_freeze(output)
    end

    results
  end

  # Process the results of all chunks with the aggregate block and return the
  # results. If no aggregate block has been specified, fall back to deep
  # merging the given data structure
  #
  # @param results [Hash<Symbol, Object>] A hash of chunk names and the output
  #   of that chunk.
  # @return [Object]
  def aggregate_results(results)
    if @aggregate
      @aggregate.call(results)
    else
      default_aggregate(results)
    end
  end

  def default_aggregate(results)
    results.values.inject do |result, current|
      Facter::Util::Values.deep_merge(result, current)
    end
  rescue Facter::Util::Values::DeepMergeError => e
    raise ArgumentError, "Could not deep merge all chunks (Original error: " +
      "#{e.message}), ensure that chunks return either an Array or Hash or " +
      "override the aggregate block", e.backtrace
  end

  # Order chunks based on their dependencies
  #
  # @return [Array<Symbol, Proc>] A list of chunk names and blocks in evaluation order.
  def order_chunks
    if not @deps.acyclic?
      raise DependencyError, "Could not order chunks; found the following dependency cycles: #{@deps.cycles.inspect}"
    end

    sorted_names = @deps.tsort

    sorted_names.map do |name|
      [name, @chunks[name]]
    end
  end

  class DependencyError < StandardError; end
end

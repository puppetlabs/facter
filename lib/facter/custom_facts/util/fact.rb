# frozen_string_literal: true

# This class represents a fact. Each fact has a name and multiple
# {Facter::Util::Resolution resolutions}.
#
# Create facts using {Facter.add}
#
# @api public
module Facter
  module Util
    class Fact
      # The name of the fact
      # @return [String]
      attr_reader :name

      # @return [String]
      # @deprecated
      attr_accessor :ldapname

      # Fact options e.g. fact_type
      attr_accessor :options

      # Weight of the resolution that was used to obtain the fact value
      attr_accessor :used_resolution_weight

      # Creates a new fact, with no resolution mechanisms. See {Facter.add}
      # for the public API for creating facts.
      # @param name [String] the fact name
      # @param options [Hash] optional parameters
      # @option options [String] :ldapname set the ldapname property on the fact
      #
      # @api private
      def initialize(name, options = {})
        @name = name.to_s.downcase.intern

        @options = Facter::Utils.deep_copy(options)
        extract_ldapname_option!(options)

        @ldapname ||= @name.to_s

        @resolves = []
        @searching = false
        @used_resolution_weight = 0

        @value = nil

        @log = Facter::Log.new(self)
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
        @options = Facter::Utils.deep_copy(@options.merge(options))
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

        resolve.options(options) unless options.empty?
        resolve.evaluate(&block) if block

        resolve
      rescue StandardError => e
        LegacyFacter
          .log_exception(e, "Unable to add resolve #{resolution_name.inspect} for fact #{@name}: #{e.message}")
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
        @resolves.each(&:flush)
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
          LegacyFacter.debug format('No resolves for %<name>s', name: @name)
          return nil
        end

        searching do
          suitable_resolutions = sort_by_weight(find_suitable_resolutions(@resolves))

          Facter::Framework::Benchmarking::Timer.measure(@name) do
            @value = find_first_real_value(suitable_resolutions)
          end

          announce_when_no_suitable_resolution(suitable_resolutions)
          announce_when_no_value_found(@value)

          @value = resolve_value
        end

        @value
      end

      # @api private
      # @deprecated
      def extract_ldapname_option!(options)
        return unless options[:ldapname]

        LegacyFacter.warnonce('ldapname is deprecated and will be removed in a future version')
        self.ldapname = options.delete(:ldapname)
      end

      private

      def resolve_value
        return Facter.core_value(name) if @value.nil?

        core_value = Facter.core_value(name) if @used_resolution_weight <= 0
        core_value.nil? ? @value : core_value
      end

      # Are we in the midst of a search?
      def searching?
        @searching
      end

      # Lock our searching process, so we never get stuck in recursion.
      def searching
        raise "Caught recursion on #{@name}" if searching?

        # If we've gotten this far, we're not already searching, so go ahead and do so.
        @searching = true
        begin
          yield
        ensure
          @searching = false
        end
      end

      def find_suitable_resolutions(resolutions)
        resolutions.find_all(&:suitable?)
      end

      def sort_by_weight(resolutions)
        # sort resolutions:
        # - descending by weight
        # - multiple facts have the same weight but different types, the :external fact take precedence
        # - multiple facts with the same weight and type, the order is preserved.
        # note: sort_by with index is slower than .sort
        # we cannot use .sort because it is not stable: https://bugs.ruby-lang.org/issues/1089
        # solution from: https://bugs.ruby-lang.org/issues/1089#note-10

        # rubocop:disable Style/NestedTernaryOperator
        idx = 0
        resolutions.sort_by do |x|
          [
            -x.weight,
            x.respond_to?(:fact_type) ? x.fact_type == :external ? 0 : 1 : 1,
            idx += 1
          ]
        end
        # rubocop:enable Style/NestedTernaryOperator
      end

      def find_first_real_value(resolutions)
        resolutions.each do |resolve|
          begin
            value = resolve.value
          rescue Facter::ResolveCustomFactError
            break
          end
          @used_resolution_weight = resolve.weight
          next if value.nil?

          log_fact_path(resolve)

          return value
        end
        nil
      end

      def log_fact_path(resolve)
        fact_type, resolved_from = if resolve.instance_of?(Facter::Core::Aggregate)
                                     ['aggregate', resolve.instance_variable_get(:@aggregate).source_location[0]]
                                   elsif resolve.fact_type == :external
                                     ['external', resolve.file]
                                   else
                                     ['custom', resolve.last_evaluated]
                                   end

        @log.debug("#{fact_type} fact #{resolve.fact.name} got resolved from: #{resolved_from}")
      end

      def announce_when_no_suitable_resolution(resolutions)
        return unless resolutions.empty?

        LegacyFacter.debug format('Found no suitable resolves of %<resolver_length> for %<name>s',
                                  resolver_length: @resolves.length, name: @name)
      end

      def announce_when_no_value_found(value)
        LegacyFacter.debug(format('value for %<name>s is still nil', name: @name)) if value.nil?
      end

      def create_or_return_resolution(resolution_name, resolution_type)
        resolve = resolution(resolution_name)

        if resolve
          if resolution_type != resolve.resolution_type
            raise ArgumentError, "Cannot return resolution #{resolution_name} with type" \
                                 " #{resolution_type}; already defined as #{resolve.resolution_type}"
          end
        else
          case resolution_type
          when :simple
            resolve = Facter::Util::Resolution.new(resolution_name, self)
          when :aggregate
            resolve = Facter::Core::Aggregate.new(resolution_name, self)
          else
            raise ArgumentError,
                  "Expected resolution type to be one of (:simple, :aggregate) but was #{resolution_type}"
          end

          @resolves << resolve
        end

        resolve
      end
    end
  end
end

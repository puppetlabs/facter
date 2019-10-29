# frozen_string_literal: true

# Manage which facts exist and how we access them.  Largely just a wrapper
# around a hash of facts.
#
# @api private
module LegacyFacter
  module Util
    class Collection
      def initialize(internal_loader, external_loader)
        @facts = {}
        @internal_loader = internal_loader
        @external_loader = external_loader
      end

      # Return a fact object by name.
      def [](name)
        value(name)
      end

      # Define a new fact or extend an existing fact.
      #
      # @param name [Symbol] The name of the fact to define
      # @param options [Hash] A hash of options to set on the fact
      #
      # @return [LegacyFacter::Util::Fact] The fact that was defined
      def define_fact(name, options = {}, &block)
        fact = create_or_return_fact(name, options)

        fact.instance_eval(&block) if block_given?

        fact
      rescue StandardError => e
        LegacyFacter.log_exception(e, "Unable to add fact #{name}: #{e}")
      end

      # Add a resolution mechanism for a named fact.  This does not distinguish
      # between adding a new fact and adding a new way to resolve a fact.
      #
      # @param name [Symbol] The name of the fact to define
      # @param options [Hash] A hash of options to set on the fact and resolution
      #
      # @return [LegacyFacter::Util::Fact] The fact that was defined
      def add(name, options = {}, &block)
        fact = create_or_return_fact(name, options)

        fact.add(options, &block)

        fact
      end

      include Enumerable

      # Iterate across all of the facts.
      def each
        load_all
        @facts.each do |name, fact|
          value = fact.value
          yield name.to_s, value unless value.nil?
        end
      end

      # Return a fact by name.
      def fact(name)
        name = canonicalize(name)

        # Try to load the fact if necessary
        load(name) unless @facts[name]

        # Try HARDER
        internal_loader.load_all unless @facts[name]

        if @facts.empty?
          LegacyFacter.warnonce("No facts loaded from #{internal_loader.search_path.join(File::PATH_SEPARATOR)}")
        end

        @facts[name]
      end

      # Flush all cached values.
      def flush
        @facts.each { |_name, fact| fact.flush }
        @external_facts_loaded = nil
      end

      # Return a list of all of the facts.
      def list
        load_all
        @facts.keys
      end

      # Build a hash of external facts
      def external_facts
        return unless @external_facts.nil?

        facts_before_load = @facts.clone
        load_external_facts

        @external_facts = @facts.dup.delete_if { |k, _| facts_before_load.key?(k) }
      end

      # Builds a hash of custom facts
      def custom_facts
        return unless @custom_facts.nil?

        facts_before_load = @facts.clone
        internal_loader.load_all

        @custom_facts = @facts.dup.delete_if { |k, _| facts_before_load.key?(k) }
      end

      def load(name)
        internal_loader.load(name)
        load_external_facts
      end

      # Load all known facts.
      def load_all
        internal_loader.load_all
        load_external_facts
      end

      attr_reader :internal_loader

      attr_reader :external_loader

      # Return a hash of all of our facts.
      def to_hash
        @facts.each_with_object({}) do |ary, h|
          value = ary[1].value
          unless value.nil?
            # For backwards compatibility, convert the fact name to a string.
            h[ary[0].to_s] = value
          end
        end
      end

      def value(name)
        fact = fact(name)

        return Facter.core_value(name) if fact.nil?

        value = fact&.value
        weight = fact&.used_resolution_weight || 0

        core_value = Facter.core_value(name)
        return core_value if weight <= 0 && core_value

        value
      end

      private

      def create_or_return_fact(name, options)
        name = canonicalize(name)

        fact = @facts[name]

        if fact.nil?
          fact = LegacyFacter::Util::Fact.new(name, options)
          @facts[name] = fact
        else
          fact.extract_ldapname_option!(options)
        end

        fact
      end

      def canonicalize(name)
        name.to_s.downcase.to_sym
      end

      def load_external_facts
        return if @external_facts_loaded

        @external_facts_loaded = true
        external_loader.load(self)
      end
    end
  end
end

# frozen_string_literal: true

module Facter
  class FactCollection < Hash
    def initialize
      super
      @log = Log.new(self)
    end

    def to_yaml
      deep_to_h.to_yaml
    end

    # Transorms a list of {Facter::ResolvedFact} into a nested collection.
    # @param facts [Array<Facter::ResolvedFact>]
    #
    # @return [FactCollection]
    #
    # @api private
    def build_fact_collection!(facts)
      facts.each do |fact|
        next if %i[core legacy].include?(fact.type) && fact.value.nil?

        bury_fact(fact)
      end

      self
    end

    def dig_fact(user_query)
      value(user_query)
    rescue KeyError, TypeError
      nil
    end

    # Collection#fetch implementation for nested collections.
    # @param user_query [String] the search terms, separated by "."
    #
    # @return [String]
    #
    # @example for fact_collection = { "os": { "name": "Darwin" } }
    #   fact_collection.fetch("os.name") #=> "Darwin"
    #
    # @api private
    def value(user_query)
      fetch(user_query) do
        split_user_query = Facter::Utils.split_user_query(user_query)
        split_user_query.reduce(self) do |memo, key|
          raise KeyError unless memo.respond_to?(:fetch)

          memo.fetch(key) { memo.fetch(key.to_s) }
        end
      end
    end

    def bury(*args)
      raise ArgumentError, '2 or more arguments required' if args.count < 2

      if args.count == 2
        self[args[0]] = args[1]
      else
        arg = args.shift
        self[arg] = FactCollection.new unless self[arg]
        self[arg].bury(*args) unless args.empty?
      end

      self
    end

    private

    def deep_to_h(collection = self)
      collection.each_pair.with_object({}) do |(key, value), hash|
        hash[key] = value.is_a?(FactCollection) ? deep_to_h(value) : value
      end
    end

    def bury_fact(fact)
      split_fact_name = extract_fact_name(fact)
      bury(*split_fact_name << fact.value)
    rescue NoMethodError
      @log.error("#{fact.type.to_s.capitalize} fact `#{fact.name}` cannot be added to collection."\
          ' The format of this fact is incompatible with other'\
          " facts that belong to `#{fact.name.split('.').first}` group")
    end

    def extract_fact_name(fact)
      case fact.type
      when :legacy
        [fact.name]
      when :custom, :external
        Options[:force_dot_resolution] == true ? fact.name.split('.') : [fact.name]
      else
        fact.name.split('.')
      end
    end
  end
end

# frozen_string_literal: true

module Facter
  class FactCollection < Hash
    def initialize
      super
      @log = Log.new(self)
    end

    def build_fact_collection!(facts)
      facts.each do |fact|
        next if %i[custom core legacy].include?(fact.type) && fact.value.nil?

        bury_fact(fact)
      end

      self
    end

    def value(*keys)
      keys.reduce(self) do |memo, key|
        memo.fetch(key.to_s)
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

    def bury_fact(fact)
      split_fact_name = extract_fact_name(fact)
      bury(*split_fact_name + fact.filter_tokens << fact.value)
    rescue NoMethodError
      @log.error("#{fact.type.to_s.capitalize} fact `#{fact.name}` cannot be added to collection."\
          ' The format of this fact is incompatible with other'\
          " facts that belong to `#{fact.name.split('.').first}` group")
    end

    def extract_fact_name(fact)
      fact.type == :legacy ? [fact.name] : fact.name.split('.')
    end
  end
end

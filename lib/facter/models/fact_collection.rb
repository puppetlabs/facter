# frozen_string_literal: true

module Facter
  class FactCollection < Hash
    def initialize
      super
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
      bury(*fact.name.split('.') + fact.filter_tokens << fact.value)
    end
  end
end

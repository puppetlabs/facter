# frozen_string_literal: true

module Facts
  module Freebsd
    module Processors
      class Count
        FACT_NAME = 'processors.count'
        ALIASES = 'processorcount'

        def call_the_resolver
          fact_value = Facter::Resolvers::Freebsd::Processors.resolve(:logical_count)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end

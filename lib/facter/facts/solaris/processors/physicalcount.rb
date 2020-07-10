# frozen_string_literal: true

module Facts
  module Solaris
    module Processors
      class Physicalcount
        FACT_NAME = 'processors.physicalcount'
        ALIASES = 'physicalprocessorcount'

        def call_the_resolver
          fact_value = Facter::Resolvers::Solaris::Processors.resolve(:physical_count)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end

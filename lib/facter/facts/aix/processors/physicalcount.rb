# frozen_string_literal: true

module Facts
  module Aix
    module Processors
      class Physicalcount
        FACT_NAME = 'processors.physicalcount'

        def call_the_resolver
          fact_value = Facter::Resolvers::Aix::Processors.resolve(:physical_count)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end

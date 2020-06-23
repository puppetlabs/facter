# frozen_string_literal: true

module Facts
  module Aix
    module Processors
      class Speed
        FACT_NAME = 'processors.speed'

        def call_the_resolver
          fact_value = Facter::Resolvers::Aix::Processors.resolve(:speed)
          speed = Facter::FactsUtils::UnitConverter.hertz_to_human_readable(fact_value)
          Facter::ResolvedFact.new(FACT_NAME, speed)
        end
      end
    end
  end
end

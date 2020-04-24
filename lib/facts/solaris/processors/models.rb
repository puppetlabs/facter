# frozen_string_literal: true

module Facts
  module Solaris
    module Processors
      class Models
        FACT_NAME = 'processors.models'
        ALIASES = 'processor.*'

        def call_the_resolver
          fact_value = Facter::Resolvers::Solaris::Processors.resolve(:models)
          facts = [Facter::ResolvedFact.new(FACT_NAME, fact_value)]
          fact_value.each_with_index do |value, index|
            facts.push(Facter::ResolvedFact.new("processor#{index}", value, :legacy))
          end
          facts
        end
      end
    end
  end
end

# frozen_string_literal: true

module Facts
  module Freebsd
    module Processors
      class Models
        FACT_NAME = 'processors.models'
        ALIASES = 'processor.*'

        def call_the_resolver
          fact_value = Facter::Resolvers::Freebsd::Processors.resolve(:models)
          return nil unless fact_value

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

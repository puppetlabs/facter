# frozen_string_literal: true

module Facts
  module Linux
    module Processors
      class Isa
        FACT_NAME = 'processors.isa'
        ALIASES = 'hardwareisa'

        def call_the_resolver
          fact_value = Facter::Resolvers::Uname.resolve(:processor)
          isa = get_isa(fact_value)

          [Facter::ResolvedFact.new(FACT_NAME, isa), Facter::ResolvedFact.new(ALIASES, isa, :legacy)]
        end

        private

        def get_isa(fact_value)
          value_split = fact_value.split('.')
          value_split.last
        end
      end
    end
  end
end

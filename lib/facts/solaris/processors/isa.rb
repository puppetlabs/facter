# frozen_string_literal: true

module Facts
  module Solaris
    module Processors
      class Isa
        FACT_NAME = 'processors.isa'
        ALIASES = 'hardwareisa'

        def call_the_resolver
          fact_value = Facter::Resolvers::Uname.resolve(:processor)
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end

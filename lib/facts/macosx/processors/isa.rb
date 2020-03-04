# frozen_string_literal: true

module Facts
  module Macosx
    module Processors
      class Isa
        FACT_NAME = 'processors.isa'

        def call_the_resolver
          fact_value = Facter::Resolvers::Uname.resolve(:processor)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end

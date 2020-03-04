# frozen_string_literal: true

module Facts
  module Macosx
    module Processors
      class Count
        FACT_NAME = 'processors.count'

        def call_the_resolver
          fact_value = Facter::Resolvers::Macosx::Processors.resolve(:logicalcount)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end

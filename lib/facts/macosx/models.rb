# frozen_string_literal: true

module Facter
  module Macosx
    class ProcessorsSpeedModels
      FACT_NAME = 'processors.models'

      def call_the_resolver
        fact_value = Resolvers::Macosx::Processors.resolve(:models)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

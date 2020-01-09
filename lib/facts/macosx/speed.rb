# frozen_string_literal: true

module Facter
  module Macosx
    class ProcessorsSpeed
      FACT_NAME = 'processors.speed'

      def call_the_resolver
        fact_value = Resolvers::Macosx::Processors.resolve(:speed)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

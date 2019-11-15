# frozen_string_literal: true

module Facter
  module Fedora
    class LoadAverage
      FACT_NAME = 'load_average'

      def call_the_resolver
        fact_value = Resolvers::Linux::LoadAverage.resolve(:loadavrg)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

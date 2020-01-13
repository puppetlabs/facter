# frozen_string_literal: true

module Facter
  module Aix
    class LoadAverages
      FACT_NAME = 'load_averages'

      def call_the_resolver
        fact_value = Resolvers::Aix::LoadAverages.resolve(:load_averages)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

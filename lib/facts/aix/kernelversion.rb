# frozen_string_literal: true

module Facter
  module Aix
    class Kernelversion
      FACT_NAME = 'kernelversion'

      def call_the_resolver
        fact_value = Resolvers::OsLevel.resolve(:build)
        kernelversion = fact_value.split('-')[0]

        ResolvedFact.new(FACT_NAME, kernelversion)
      end
    end
  end
end

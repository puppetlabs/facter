# frozen_string_literal: true

module Facts
  module Aix
    class Kernelversion
      FACT_NAME = 'kernelversion'

      def call_the_resolver
        fact_value = Facter::Resolvers::OsLevel.resolve(:build)
        kernelversion = fact_value.split('-')[0]

        Facter::ResolvedFact.new(FACT_NAME, kernelversion)
      end
    end
  end
end

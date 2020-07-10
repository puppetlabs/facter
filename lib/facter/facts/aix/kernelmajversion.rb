# frozen_string_literal: true

module Facts
  module Aix
    class Kernelmajversion
      FACT_NAME = 'kernelmajversion'

      def call_the_resolver
        fact_value = Facter::Resolvers::OsLevel.resolve(:build)
        kernelmajversion = fact_value.split('-')[0]

        Facter::ResolvedFact.new(FACT_NAME, kernelmajversion)
      end
    end
  end
end

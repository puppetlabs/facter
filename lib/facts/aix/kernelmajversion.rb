# frozen_string_literal: true

module Facter
  module Aix
    class Kernelmajversion
      FACT_NAME = 'kernelmajversion'

      def call_the_resolver
        fact_value = Resolvers::OsLevel.resolve(:build)
        kernelmajversion = fact_value.split('-')[0]

        ResolvedFact.new(FACT_NAME, kernelmajversion)
      end
    end
  end
end

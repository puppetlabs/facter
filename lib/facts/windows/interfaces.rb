# frozen_string_literal: true

module Facter
  module Windows
    class Interfaces
      FACT_NAME = 'interfaces'

      def call_the_resolver
        fact_value = Resolvers::Networking.resolve(:interfaces).keys.join(',')

        ResolvedFact.new(FACT_NAME, fact_value, :legacy)
      end
    end
  end
end

# frozen_string_literal: true

module Facter
  module Windows
    class NetworkingDomain
      FACT_NAME = 'networking.domain'

      def call_the_resolver
        fact_value = Resolvers::Domain.resolve(:domain)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

# frozen_string_literal: true

module Facter
  module Windows
    class NetworkingDomain
      FACT_NAME = 'networking.domain'
      ALIASES = 'domain'

      def call_the_resolver
        fact_value = Resolvers::Networking.resolve(:domain)

        [ResolvedFact.new(FACT_NAME, fact_value), ResolvedFact.new(ALIASES, fact_value, :legacy)]
      end
    end
  end
end

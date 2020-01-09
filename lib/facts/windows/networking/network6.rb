# frozen_string_literal: true

module Facter
  module Windows
    class NetworkingNetwork6
      FACT_NAME = 'networking.network6'
      ALIASES = 'network6'

      def call_the_resolver
        fact_value = Resolvers::Networking.resolve(:network6)

        [ResolvedFact.new(FACT_NAME, fact_value), ResolvedFact.new(ALIASES, fact_value, :legacy)]
      end
    end
  end
end

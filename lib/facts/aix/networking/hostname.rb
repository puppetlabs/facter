# frozen_string_literal: true

module Facter
  module Aix
    class NetworkingHostname
      FACT_NAME = 'networking.hostname'
      ALIASES = 'hostname'

      def call_the_resolver
        fact_value = Facter::Resolvers::Hostname.resolve(:hostname)
        [ResolvedFact.new(FACT_NAME, fact_value), ResolvedFact.new(ALIASES, fact_value, :legacy)]
      end
    end
  end
end

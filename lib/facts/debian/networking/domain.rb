# frozen_string_literal: true

module Facter
  module Debian
    class NetworkingDomain
      FACT_NAME = 'networking.domain'

      def call_the_resolver
        fact_value = Facter::Resolvers::NetworkingDomain.resolve(:networking_domain)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

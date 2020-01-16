# frozen_string_literal: true

module Facter
  module Debian
    class NetworkingFqdn
      FACT_NAME = 'networking.fqdn'

      def call_the_resolver
        hostname = Resolvers::Hostname.resolve(:hostname)
        domain = Resolvers::NetworkingDomain.resolve(:networking_domain)
        fact_value = hostname + '.' + domain
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

# frozen_string_literal: true

module Facts
  module Windows
    module Networking
      class Fqdn
        FACT_NAME = 'networking.fqdn'
        ALIASES = 'fqdn'

        def call_the_resolver
          domain = Facter::Resolvers::Windows::Networking.resolve(:domain)
          hostname = Facter::Resolvers::Hostname.resolve(:hostname)
          return Facter::ResolvedFact.new(FACT_NAME, nil) if !hostname || hostname.empty?

          fact_value = [hostname, domain].compact.join('.')

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end

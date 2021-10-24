# frozen_string_literal: true

module Facts
  module Linux
    module Networking
      class Fqdn
        FACT_NAME = 'networking.fqdn'
        ALIASES = 'fqdn'

        def call_the_resolver
          fact_value = Facter::Resolvers::Linux::Hostname.resolve(:fqdn)

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end

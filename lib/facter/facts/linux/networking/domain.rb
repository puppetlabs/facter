# frozen_string_literal: true

module Facts
  module Linux
    module Networking
      class Domain
        FACT_NAME = 'networking.domain'
        ALIASES = 'domain'

        def call_the_resolver
          fact_value = Facter::Resolvers::Hostname.resolve(:domain)

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end

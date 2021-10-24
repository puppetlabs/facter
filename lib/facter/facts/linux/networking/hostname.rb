# frozen_string_literal: true

module Facts
  module Linux
    module Networking
      class Hostname
        FACT_NAME = 'networking.hostname'
        ALIASES = 'hostname'

        def call_the_resolver
          fact_value = Facter::Resolvers::Linux::Hostname.resolve(:hostname)

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end

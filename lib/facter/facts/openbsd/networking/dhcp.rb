# frozen_string_literal: true

module Facts
  module Openbsd
    module Networking
      class Dhcp
        FACT_NAME = 'networking.dhcp'

        def call_the_resolver
          fact_value = Facter::Resolvers::Openbsd::Dhcp.resolve(:dhcp)

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end

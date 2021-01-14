# frozen_string_literal: true

module Facts
  module Linux
    module Networking
      class Dhcp
        FACT_NAME = 'networking.dhcp'

        def call_the_resolver
          fact_value = Facter::Resolvers::Linux::Networking.resolve(:dhcp)

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end

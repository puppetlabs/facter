# frozen_string_literal: true

module Facts
  module Windows
    module Networking
      class Netmask
        FACT_NAME = 'networking.netmask'
        ALIASES = 'netmask'

        def call_the_resolver
          fact_value = Facter::Resolvers::Windows::Networking.resolve(:netmask)

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end

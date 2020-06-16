# frozen_string_literal: true

module Facts
  module Macosx
    module Networking
      class Ip6
        FACT_NAME = 'networking.ip6'
        ALIASES = 'ipaddress6'

        def call_the_resolver
          interfaces = Facter::Resolvers::Macosx::Networking.resolve(:interfaces)
          primary = Facter::Resolvers::Macosx::Networking.resolve(:primary_interface)

          fact_value = interfaces.dig(primary, :bindings6, 0, :address) if interfaces

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end

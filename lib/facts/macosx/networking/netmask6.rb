# frozen_string_literal: true

module Facts
  module Macosx
    module Networking
      class Netmask6
        FACT_NAME = 'networking.netmask6'
        ALIASES = 'netmask6'

        def call_the_resolver
          interfaces = Facter::Resolvers::Macosx::Networking.resolve(:interfaces)
          primary = Facter::Resolvers::Macosx::Networking.resolve(:primary_interface)

          fact_value = interfaces.dig(primary, :bindings6, 0, :netmask) if interfaces

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end
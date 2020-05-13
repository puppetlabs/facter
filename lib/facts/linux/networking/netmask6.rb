# frozen_string_literal: true

module Facts
  module Linux
    module Networking
      class Netmask6
        FACT_NAME = 'networking.netmask6'
        ALIASES = 'netmask6'

        def call_the_resolver
          interfaces = Facter::Resolvers::NetworkingLinux.resolve(:interfaces)
          primary = Facter::Resolvers::NetworkingLinux.resolve(:primary_interface)

          fact_value = interfaces[primary][:netmask6] if interfaces && interfaces[primary]

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end

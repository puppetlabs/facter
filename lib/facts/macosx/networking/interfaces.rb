# frozen_string_literal: true

module Facts
  module Macosx
    module Networking
      class Interfaces
        FACT_NAME = 'networking.interfaces'

        def call_the_resolver
          interfaces = Facter::Resolvers::Macosx::Networking.resolve(:interfaces)
          dhcp = Facter::Resolvers::Macosx::Networking.resolve(:dhcp)
          primary = Facter::Resolvers::Macosx::Networking.resolve(:primary_interface)

          interfaces[primary][:dhcp] = dhcp if interfaces && interfaces[primary]

          Facter::ResolvedFact.new(FACT_NAME, interfaces)
        end
      end
    end
  end
end

# frozen_string_literal: true

module Facts
  module Macosx
    module Networking
      class Mtu
        FACT_NAME = 'networking.mtu'

        def call_the_resolver
          interfaces = Facter::Resolvers::Macosx::Networking.resolve(:interfaces)
          primary = Facter::Resolvers::Macosx::Networking.resolve(:primary_interface)

          fact_value = interfaces.dig(primary, :mtu) if interfaces

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end

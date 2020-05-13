# frozen_string_literal: true

module Facts
  module Linux
    module Networking
      class Mtu
        FACT_NAME = 'networking.mtu'

        def call_the_resolver
          interfaces = Facter::Resolvers::NetworkingLinux.resolve(:interfaces)
          primary = Facter::Resolvers::NetworkingLinux.resolve(:primary_interface)

          fact_value = interfaces[primary][:mtu] if interfaces && interfaces[primary]

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end

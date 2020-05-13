# frozen_string_literal: true

module Facts
  module Linux
    module Networking
      class Scope6
        FACT_NAME = 'networking.scope6'

        def call_the_resolver
          interfaces = Facter::Resolvers::NetworkingLinux.resolve(:interfaces)
          primary = Facter::Resolvers::NetworkingLinux.resolve(:primary_interface)

          fact_value = interfaces[primary][:scope6] if interfaces && interfaces[primary]

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end

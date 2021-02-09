# frozen_string_literal: true

module Facts
  module Linux
    module Networking
      class Mtu
        FACT_NAME = 'networking.mtu'

        def call_the_resolver
          fact_value = Facter::Resolvers::Linux::Networking.resolve(:mtu)

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end

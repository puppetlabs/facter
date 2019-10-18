# frozen_string_literal: true

module Facter
  module Windows
    class NetworkingMtu
      FACT_NAME = 'networking.mtu'

      def call_the_resolver
        fact_value = Resolvers::Networking.resolve(:mtu)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

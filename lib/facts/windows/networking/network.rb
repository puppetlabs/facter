# frozen_string_literal: true

module Facter
  module Windows
    class NetworkingNetwork
      FACT_NAME = 'networking.network'

      def call_the_resolver
        fact_value = Resolvers::Networking.resolve(:network)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

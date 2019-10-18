# frozen_string_literal: true

module Facter
  module Windows
    class NetworkingDhcp
      FACT_NAME = 'networking.dhcp'

      def call_the_resolver
        fact_value = Resolvers::Networking.resolve(:dhcp)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

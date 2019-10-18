# frozen_string_literal: true

module Facter
  module Windows
    class NetworkingNetmask6
      FACT_NAME = 'networking.netmask6'

      def call_the_resolver
        fact_value = Resolvers::Networking.resolve(:netmask6)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

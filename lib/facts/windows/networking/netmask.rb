# frozen_string_literal: true

module Facter
  module Windows
    class NetworkingNetmask
      FACT_NAME = 'networking.netmask'

      def call_the_resolver
        fact_value = Resolvers::Networking.resolve(:netmask)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

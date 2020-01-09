# frozen_string_literal: true

module Facter
  module Windows
    class NetworkingMac
      FACT_NAME = 'networking.mac'
      ALIASES = 'macaddress'

      def call_the_resolver
        fact_value = Resolvers::Networking.resolve(:mac)

        [ResolvedFact.new(FACT_NAME, fact_value), ResolvedFact.new(ALIASES, fact_value, :legacy)]
      end
    end
  end
end

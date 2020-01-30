# frozen_string_literal: true

module Facter
  module Solaris
    class NetworkingIpaddress
      FACT_NAME = 'networking.ip'

      def call_the_resolver
        fact_value = Facter::Resolvers::Solaris::Ipaddress.resolve(:ip)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

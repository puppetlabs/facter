# frozen_string_literal: true

module Facter
  module Macosx
    class NetworkingIpaddress
      FACT_NAME = 'networking.ip'

      def call_the_resolver
        fact_value = Facter::Resolvers::Macosx::Ipaddress.resolve(:ip)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

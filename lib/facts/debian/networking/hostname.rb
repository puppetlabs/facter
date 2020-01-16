# frozen_string_literal: true

module Facter
  module Debian
    class NetworkingHostname
      FACT_NAME = 'networking.hostname'

      def call_the_resolver
        fact_value = Facter::Resolvers::Hostname.resolve(:hostname)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

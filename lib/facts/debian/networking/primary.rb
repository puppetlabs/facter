# frozen_string_literal: true

module Facter
  module Debian
    class NetworkingPrimary
      FACT_NAME = 'networking.primary'

      def call_the_resolver
        fact_value = Resolvers::NetworkingLinux.resolve(:primary_interface)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

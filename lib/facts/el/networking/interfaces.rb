# frozen_string_literal: true

module Facter
  module El
    class NetworkingInterfaces
      FACT_NAME = 'networking.interfaces'

      def call_the_resolver
        fact_value = Resolvers::NetworkingLinux.resolve(:interfaces)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

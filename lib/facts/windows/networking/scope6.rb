# frozen_string_literal: true

module Facter
  module Windows
    class NetworkingScope6
      FACT_NAME = 'networking.scope6'

      def call_the_resolver
        fact_value = Resolvers::Networking.resolve(:scope6)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

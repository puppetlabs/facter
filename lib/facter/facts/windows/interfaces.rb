# frozen_string_literal: true

module Facts
  module Windows
    class Interfaces
      FACT_NAME = 'interfaces'

      def call_the_resolver
        fact_value = Facter::Resolvers::Networking.resolve(:interfaces)

        Facter::ResolvedFact.new(FACT_NAME, fact_value ? fact_value.keys.join(',') : nil, :legacy)
      end
    end
  end
end

# frozen_string_literal: true

module Facts
  module Aix
    class Interfaces
      FACT_NAME = 'interfaces'
      TYPE = :legacy

      def call_the_resolver
        fact_value = Facter::Resolvers::Aix::Networking.resolve(:interfaces)
        fact_value = fact_value&.any? ? fact_value.keys.sort.join(',') : nil

        Facter::ResolvedFact.new(FACT_NAME, fact_value, :legacy)
      end
    end
  end
end

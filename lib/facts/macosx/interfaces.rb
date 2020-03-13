# frozen_string_literal: true

module Facts
  module Macosx
    class Interfaces
      FACT_NAME = 'interfaces'

      def call_the_resolver
        fact_value = Facter::Resolvers::Macosx::Ipaddress.resolve(:interfaces)

        Facter::ResolvedFact.new(FACT_NAME, fact_value, :legacy)
      end
    end
  end
end

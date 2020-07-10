# frozen_string_literal: true

module Facts
  module Debian
    class Lsbdistid
      FACT_NAME = 'lsbdistid'
      TYPE = :legacy

      def call_the_resolver
        fact_value = Facter::Resolvers::LsbRelease.resolve(:distributor_id)

        Facter::ResolvedFact.new(FACT_NAME, fact_value, :legacy)
      end
    end
  end
end

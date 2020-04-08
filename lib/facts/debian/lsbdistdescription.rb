# frozen_string_literal: true

module Facts
  module Debian
    class Lsbdistdescription
      FACT_NAME = 'lsbdistdescription'
      TYPE = :legacy

      def call_the_resolver
        fact_value = Facter::Resolvers::LsbRelease.resolve(:description)

        Facter::ResolvedFact.new(FACT_NAME, fact_value, :legacy)
      end
    end
  end
end

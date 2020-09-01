# frozen_string_literal: true

module Facts
  module Debian
    class Lsbdistcodename
      FACT_NAME = 'lsbdistcodename'
      TYPE = :legacy

      def call_the_resolver
        fact_value = Facter::Resolvers::LsbRelease.resolve(:codename)

        Facter::ResolvedFact.new(FACT_NAME, fact_value, :legacy)
      end
    end
  end
end

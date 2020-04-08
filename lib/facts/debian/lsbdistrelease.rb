# frozen_string_literal: true

module Facts
  module Debian
    class Lsbdistrelease
      FACT_NAME = 'lsbdistrelease'
      ALIASES = %w[lsbmajdistrelease lsbminordistrelease].freeze
      TYPE = :legacy

      def call_the_resolver
        fact_value = Facter::Resolvers::LsbRelease.resolve(:release)

        return Facter::ResolvedFact.new(FACT_NAME, nil, :legacy) unless fact_value

        version = fact_value.split('.')

        [Facter::ResolvedFact.new(FACT_NAME, fact_value, :legacy),
         Facter::ResolvedFact.new(ALIASES[0], version[0], :legacy),
         Facter::ResolvedFact.new(ALIASES[1], version[1], :legacy)]
      end
    end
  end
end

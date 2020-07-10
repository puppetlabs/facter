# frozen_string_literal: true

module Facts
  module Aix
    class Kernelrelease
      FACT_NAME = 'kernelrelease'

      def call_the_resolver
        fact_value = Facter::Resolvers::OsLevel.resolve(:build).strip

        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

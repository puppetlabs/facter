# frozen_string_literal: true

module Facts
  module Freebsd
    class Kernelrelease
      FACT_NAME = 'kernelrelease'

      def call_the_resolver
        fact_value = Facter::Resolvers::Uname.resolve(:kernelrelease)
        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

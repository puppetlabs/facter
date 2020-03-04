# frozen_string_literal: true

module Facts
  module Sles
    class Kernelmajversion
      FACT_NAME = 'kernelmajversion'

      def call_the_resolver
        version_numbers = Facter::Resolvers::Uname.resolve(:kernelrelease).split('-').first.split('.')
        fact_value = version_numbers[0..1].join('.')
        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

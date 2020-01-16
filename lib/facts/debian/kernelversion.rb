# frozen_string_literal: true

module Facter
  module Debian
    class Kernelversion
      FACT_NAME = 'kernelversion'

      def call_the_resolver
        version_numbers = Resolvers::Uname.resolve(:kernelrelease).scan(/\d+/)
        fact_value = version_numbers[0..2].join('.')
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

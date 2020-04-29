# frozen_string_literal: true

module Facts
  module Bsd
    class Kernelversion
      FACT_NAME = 'kernelversion'

      def call_the_resolver
        fact_value = Facter::Resolvers::Uname.resolve(:kernelrelease).sub(/\A(\d+(\.\d+)*).*/, '\1')
        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

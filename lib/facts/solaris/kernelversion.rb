# frozen_string_literal: true

module Facts
  module Solaris
    class Kernelversion
      FACT_NAME = 'kernelversion'

      def call_the_resolver
        fact_value = Facter::Resolvers::Uname.resolve(:kernelversion)
        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

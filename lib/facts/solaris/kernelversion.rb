# frozen_string_literal: true

module Facter
  module Solaris
    class Kernelversion
      FACT_NAME = 'kernelversion'

      def call_the_resolver
        fact_value = Resolvers::Uname.resolve(:kernelversion)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

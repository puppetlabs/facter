# frozen_string_literal: true

module Facter
  module Windows
    class KernelMajorVersion
      FACT_NAME = 'kernelmajorversion'

      def call_the_resolver
        fact_value = Resolvers::KernelResolver.resolve(:kernelmajorversion)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

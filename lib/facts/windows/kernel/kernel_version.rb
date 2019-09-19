# frozen_string_literal: true

module Facter
  module Windows
    class KernelVersion
      FACT_NAME = 'kernelversion'

      def call_the_resolver
        fact_value = KernelResolver.resolve(:kernelversion)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

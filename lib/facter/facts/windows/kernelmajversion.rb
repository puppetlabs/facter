# frozen_string_literal: true

module Facts
  module Windows
    class Kernelmajversion
      FACT_NAME = 'kernelmajversion'

      def call_the_resolver
        fact_value = Facter::Resolvers::Kernel.resolve(:kernelmajorversion)

        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

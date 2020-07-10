# frozen_string_literal: true

module Facts
  module Windows
    class Kernel
      FACT_NAME = 'kernel'

      def call_the_resolver
        fact_value = Facter::Resolvers::Kernel.resolve(:kernel)

        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

# frozen_string_literal: true

module Facter
  module Windows
    class IsVirtual
      FACT_NAME = 'is_virtual'

      def call_the_resolver
        fact_value = Resolver::VirtualizationResolver.resolve(:is_virtual)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

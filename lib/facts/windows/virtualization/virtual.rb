# frozen_string_literal: true

module Facter
  module Windows
    class Virtual
      FACT_NAME = 'virtual'

      def call_the_resolver
        fact_value = Resolver::VirtualizationResolver.resolve(:virtual)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

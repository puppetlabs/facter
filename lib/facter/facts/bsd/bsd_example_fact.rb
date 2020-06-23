# frozen_string_literal: true

module Facts
  module Bsd
    class ExampleFact
      FACT_NAME = 'example.fact'

      def call_the_resolver
        fact_value = 'example_fact_value'
        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

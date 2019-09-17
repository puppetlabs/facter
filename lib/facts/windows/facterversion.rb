# frozen_string_literal: true

module Facter
  module Windows
    class Facterversion
      FACT_NAME = 'facterversion'

      def call_the_resolver
        fact_value = FacterversionResolver.resolve(:facterversion)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

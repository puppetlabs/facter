# frozen_string_literal: true

module Facter
  module Windows
    class OsFamily
      FACT_NAME = 'os.family'

      def call_the_resolver
        fact_value = Resolvers::Kernel.resolve(:kernel)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

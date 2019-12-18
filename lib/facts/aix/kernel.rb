# frozen_string_literal: true

module Facter
  module Aix
    class Kernel
      FACT_NAME = 'kernel'

      def call_the_resolver
        fact_value = Resolvers::OsLevel.resolve(:kernel)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

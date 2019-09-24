# frozen_string_literal: true

module Facter
  module Windows
    class OsWindowsProductName
      FACT_NAME = 'os.windows.product_name'

      def call_the_resolver
        fact_value = Resolvers::ProductRelease.resolve(:product_name)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

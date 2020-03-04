# frozen_string_literal: true

module Facts
  module Windows
    module Os
      module Windows
        class ProductName
          FACT_NAME = 'os.windows.product_name'
          ALIASES = 'windows_product_name'

          def call_the_resolver
            fact_value = Facter::Resolvers::ProductRelease.resolve(:product_name)

            [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end

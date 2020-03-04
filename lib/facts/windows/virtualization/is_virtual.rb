# frozen_string_literal: true

module Facts
  module Windows
    module Virtualization
      class IsVirtual
        FACT_NAME = 'is_virtual'

        def call_the_resolver
          fact_value = Facter::Resolvers::Virtualization.resolve(:is_virtual)

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end

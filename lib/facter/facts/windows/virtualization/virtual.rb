# frozen_string_literal: true

module Facts
  module Windows
    module Virtualization
      class Virtual
        FACT_NAME = 'virtual'

        def call_the_resolver
          fact_value = Facter::Resolvers::Virtualization.resolve(:virtual)

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end

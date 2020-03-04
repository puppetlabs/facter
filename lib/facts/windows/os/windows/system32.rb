# frozen_string_literal: true

module Facts
  module Windows
    module Os
      module Windows
        class System32
          FACT_NAME = 'os.windows.system32'
          ALIASES = 'system32'

          def call_the_resolver
            fact_value = Facter::Resolvers::System32.resolve(:system32)

            [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Facts
  module Windows
    module Os
      module Windows
        class EditionId
          FACT_NAME = 'os.windows.edition_id'
          ALIASES = 'windows_edition_id'

          def call_the_resolver
            fact_value = Facter::Resolvers::ProductRelease.resolve(:edition_id)

            [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end

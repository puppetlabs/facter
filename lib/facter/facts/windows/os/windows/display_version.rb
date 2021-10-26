# frozen_string_literal: true

module Facts
  module Windows
    module Os
      module Windows
        class DisplayVersion
          FACT_NAME = 'os.windows.display_version'
          ALIASES = 'windows_display_version'

          def call_the_resolver
            fact_value = Facter::Resolvers::ProductRelease.resolve(:display_version)

            [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end

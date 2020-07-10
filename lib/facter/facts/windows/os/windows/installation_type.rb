# frozen_string_literal: true

module Facts
  module Windows
    module Os
      module Windows
        class InstallationType
          FACT_NAME = 'os.windows.installation_type'
          ALIASES = 'windows_installation_type'

          def call_the_resolver
            fact_value = Facter::Resolvers::ProductRelease.resolve(:installation_type)

            [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end

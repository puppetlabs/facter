# frozen_string_literal: true

module Facts
  module Sles
    module Os
      module Distro
        class Codename
          FACT_NAME = 'os.distro.codename'

          def call_the_resolver
            fact_value = Facter::Resolvers::OsRelease.resolve(:version_codename)
            fact_value = 'n/a' if !fact_value || fact_value.empty?

            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end

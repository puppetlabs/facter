# frozen_string_literal: true

module Facts
  module Debian
    module Os
      module Distro
        class Id
          FACT_NAME = 'os.distro.id'

          def call_the_resolver
            fact_value = Facter::Resolvers::OsRelease.resolve(:id).capitalize

            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Facts
  module Debian
    module Os
      module Distro
        class Description
          FACT_NAME = 'os.distro.description'

          def call_the_resolver
            fact_value = Facter::Resolvers::OsRelease.resolve(:pretty_name)

            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end

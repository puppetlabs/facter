# frozen_string_literal: true

module Facts
  module El
    module Os
      module Distro
        class Specification
          FACT_NAME = 'os.distro.specification'
          ALIASES = 'lsbrelease'

          def call_the_resolver
            fact_value = Facter::Resolvers::LsbRelease.resolve(:lsb_version)

            [Facter::ResolvedFact.new(FACT_NAME, fact_value),
             Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end

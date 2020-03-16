# frozen_string_literal: true

module Facts
  module Debian
    module Os
      module Distro
        class Codename
          FACT_NAME = 'os.distro.codename'
          ALIASES = 'lsbdistcodename'

          def call_the_resolver
            fact_value = Facter::Resolvers::LsbRelease.resolve(:codename)

            [Facter::ResolvedFact.new(FACT_NAME, fact_value),
             Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Facts
  module Sles
    module Os
      module Distro
        class Description
          FACT_NAME = 'os.distro.description'
          ALIASES = 'lsbdistdescription'

          def call_the_resolver
            fact_value = Facter::Resolvers::LsbRelease.resolve(:description)

            [Facter::ResolvedFact.new(FACT_NAME, fact_value),
             Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end

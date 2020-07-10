# frozen_string_literal: true

module Facts
  module Linux
    module Os
      module Distro
        class Id
          FACT_NAME = 'os.distro.id'
          ALIASES = 'lsbdistid'

          def call_the_resolver
            fact_value = Facter::Resolvers::LsbRelease.resolve(:distributor_id)

            [Facter::ResolvedFact.new(FACT_NAME, fact_value),
             Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end

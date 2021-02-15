# frozen_string_literal: true

module Facts
  module Rhel
    module Os
      module Distro
        class Codename
          FACT_NAME = 'os.distro.codename'

          def call_the_resolver
            fact_value = Facter::Resolvers::RedHatRelease.resolve(:codename)

            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end

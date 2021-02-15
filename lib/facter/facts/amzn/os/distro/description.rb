# frozen_string_literal: true

module Facts
  module Amzn
    module Os
      module Distro
        class Description
          FACT_NAME = 'os.distro.description'

          def call_the_resolver
            fact_value = Facter::Resolvers::SpecificReleaseFile.resolve(
              :release, release_file: '/etc/system-release'
            )

            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end

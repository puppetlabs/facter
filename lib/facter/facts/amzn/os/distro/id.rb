# frozen_string_literal: true

module Facts
  module Amzn
    module Os
      module Distro
        class Id
          FACT_NAME = 'os.distro.id'

          def call_the_resolver
            fact_value = Facter::Resolvers::SpecificReleaseFile.resolve(
              :release, release_file: '/etc/system-release'
            ).split('release')[0].split.reject { |el| el.casecmp('linux').zero? }.join

            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end

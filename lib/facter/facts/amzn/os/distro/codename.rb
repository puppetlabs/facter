# frozen_string_literal: true

module Facts
  module Amzn
    module Os
      module Distro
        class Codename
          FACT_NAME = 'os.distro.codename'

          def call_the_resolver
            fact_value = Facter::Resolvers::SpecificReleaseFile.resolve(
              :release, release_file: '/etc/system-release'
            ).match(/.*release.*(\(.*\)).*/)

            fact_value = fact_value[1].gsub(/\(|\)/, '') if fact_value
            fact_value ||= 'n/a'

            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end

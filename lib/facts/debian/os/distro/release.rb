# frozen_string_literal: true

module Facts
  module Debian
    module Os
      module Distro
        class Release
          FACT_NAME = 'os.distro.release'

          def call_the_resolver
            fact_value = determine_release_for_os

            return Facter::ResolvedFact.new(FACT_NAME, nil) unless fact_value

            versions = fact_value.split('.')
            release = {}
            release['full'] = fact_value
            release['major'] = versions[0]
            release['minor'] = versions[1].gsub(/^0([1-9])/, '\1') if versions[1]
            Facter::ResolvedFact.new(FACT_NAME, release)
          end

          private

          def determine_release_for_os
            os_name = Facter::Resolvers::OsRelease.resolve(:name)

            if os_name =~ /Debian|Raspbian/
              Facter::Resolvers::DebianVersion.resolve(:version)
            else
              Facter::Resolvers::OsRelease.resolve(:version_id)
            end
          end
        end
      end
    end
  end
end

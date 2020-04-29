# frozen_string_literal: true

module Facts
  module Debian
    module Os
      module Distro
        class Release
          FACT_NAME = 'os.distro.release'

          def call_the_resolver
            fact_value = determine_release_for_os

            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end

          private

          def determine_release_for_os
            os_name = Facter::Resolvers::OsRelease.resolve(:name)

            if os_name =~ /Debian|Raspbian/
              release = Facter::Resolvers::DebianVersion.resolve(:version)
              return unless release

              versions = release.split('.')
              fact_value = {}
              fact_value['full'] = release
              fact_value['major'] = versions[0]
              fact_value['minor'] = versions[1].gsub(/^0([1-9])/, '\1') if versions[1]
              fact_value
            else
              release = Facter::Resolvers::OsRelease.resolve(:version_id)
              return unless release

              {
                'full' => release,
                'major' => release
              }
            end
          end
        end
      end
    end
  end
end

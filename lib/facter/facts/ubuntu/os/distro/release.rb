# frozen_string_literal: true

module Facts
  module Ubuntu
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

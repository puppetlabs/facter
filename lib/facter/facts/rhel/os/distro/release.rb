# frozen_string_literal: true

module Facts
  module Rhel
    module Os
      module Distro
        class Release
          FACT_NAME = 'os.distro.release'
          ALIASES = %w[lsbdistrelease lsbmajdistrelease lsbminordistrelease].freeze

          def call_the_resolver
            version = determine_release_version

            return Facter::ResolvedFact.new(FACT_NAME, nil) unless version

            [Facter::ResolvedFact.new(FACT_NAME, version),
             Facter::ResolvedFact.new(ALIASES[0], version['full'], :legacy),
             Facter::ResolvedFact.new(ALIASES[1], version['major'], :legacy),
             Facter::ResolvedFact.new(ALIASES[2], version['minor'], :legacy)]
          end

          def determine_release_version
            version = Facter::Resolvers::RedHatRelease.resolve(:version)
            version ||= Facter::Resolvers::OsRelease.resolve(:version_id)

            Facter::Util::Facts.release_hash_from_string(version)
          end
        end
      end
    end
  end
end

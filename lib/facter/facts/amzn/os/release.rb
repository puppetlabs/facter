# frozen_string_literal: true

module Facts
  module Amzn
    module Os
      class Release
        FACT_NAME = 'os.release'
        ALIASES = %w[operatingsystemmajrelease operatingsystemrelease].freeze

        def call_the_resolver
          version = determine_release_version

          return Facter::ResolvedFact.new(FACT_NAME, nil) unless version

          [Facter::ResolvedFact.new(FACT_NAME, version),
           Facter::ResolvedFact.new(ALIASES.first, version['major'], :legacy),
           Facter::ResolvedFact.new(ALIASES.last, version['full'], :legacy)]
        end

        def determine_release_version
          # For backwards compatibility, use system-release for AL1/AL2
          version = Facter::Resolvers::ReleaseFromFirstLine.resolve(:release, release_file: '/etc/system-release')
          if !version.nil? && version != '2'
            # Use os-release for AL2023 and up
            version = Facter::Resolvers::Amzn::OsReleaseRpm.resolve(:version)
          end
          version ||= Facter::Resolvers::OsRelease.resolve(:version_id)

          Facter::Util::Facts.release_hash_from_string(version)
        end
      end
    end
  end
end

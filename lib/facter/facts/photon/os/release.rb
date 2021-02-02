# frozen_string_literal: true

module Facts
  module Photon
    module Os
      class Release
        FACT_NAME = 'os.release'
        ALIASES = %w[operatingsystemmajrelease operatingsystemrelease].freeze

        def call_the_resolver
          version = from_specific_file || from_os_release

          return Facter::ResolvedFact.new(FACT_NAME, nil) unless version

          [Facter::ResolvedFact.new(FACT_NAME, version),
           Facter::ResolvedFact.new(ALIASES.first, version['major'], :legacy),
           Facter::ResolvedFact.new(ALIASES.last, version['full'], :legacy)]
        end

        def from_specific_file
          version = Facter::Resolvers::SpecificReleaseFile.resolve(:release,
                                                                   { release_file: '/etc/lsb-release',
                                                                     regex: /DISTRIB_RELEASE="(\d+)\.(\d+)/ })
          return if version.nil? || version[1].nil? || version[2].nil?

          major = version[1].to_s
          minor = version[2].to_s
          version_data = major + '.' + minor

          {
            'full' => version_data,
            'major' => major,
            'minor' => minor
          }
        end

        def from_os_release
          version = Facter::Resolvers::OsRelease.resolve(:version_id)

          Facter::Util::Facts.release_hash_from_string(version)
        end
      end
    end
  end
end

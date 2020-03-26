# frozen_string_literal: true

module Facts
  module Debian
    module Os
      class Release
        FACT_NAME = 'os.release'
        ALIASES = %w[operatingsystemmajrelease operatingsystemrelease].freeze

        def call_the_resolver
          fact_value = determine_release_for_os

          return Facter::ResolvedFact.new(FACT_NAME, nil) unless fact_value

          versions = fact_value.split('.')
          release = {
            'full' => fact_value,
            'major' => versions[0],
            'minor' => versions[1].gsub(/^0([1-9])/, '\1')
          }

          [Facter::ResolvedFact.new(FACT_NAME, release),
           Facter::ResolvedFact.new(ALIASES.first, versions[0], :legacy),
           Facter::ResolvedFact.new(ALIASES.last, fact_value, :legacy)]
        end

        private

        def determine_release_for_os
          os_name = Facter::Resolvers::OsRelease.resolve(:name)

          if os_name =~ /Debian/
            Facter::Resolvers::DebianVersion.resolve(:version)
          else
            Facter::Resolvers::OsRelease.resolve(:version_id)
          end
        end
      end
    end
  end
end

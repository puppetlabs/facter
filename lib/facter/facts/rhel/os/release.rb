# frozen_string_literal: true

module Facts
  module Rhel
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
          version = Facter::Resolvers::RedHatRelease.resolve(:version)
          version ||= Facter::Resolvers::OsRelease.resolve(:version_id)

          return unless version

          versions = version.split('.')
          fact_value = {}
          fact_value['full'] = version
          fact_value['major'] = versions[0]
          fact_value['minor'] = versions[1].gsub(/^0([1-9])/, '\1') if versions[1]
          fact_value
        end
      end
    end
  end
end

# frozen_string_literal: true

module Facts
  module Freebsd
    module Os
      class Release
        FACT_NAME = 'os.release'
        ALIASES = %w[operatingsystemmajrelease operatingsystemrelease].freeze

        def call_the_resolver
          installed_userland = Facter::Resolvers::Freebsd::FreebsdVersion.resolve(:installed_userland)

          return Facter::ResolvedFact.new(FACT_NAME, nil) if !installed_userland || installed_userland.empty?

          value = build_release_hash_from_version(installed_userland)

          [Facter::ResolvedFact.new(FACT_NAME, value),
           Facter::ResolvedFact.new(ALIASES.first, value[:major], :legacy),
           Facter::ResolvedFact.new(ALIASES.last, installed_userland, :legacy)]
        end

        private

        def build_release_hash_from_version(version_string)
          version, branch_value = version_string.split('-', 2)
          major_value, minor_value = version.split('.')
          patchlevel_value = branch_value.split('-p')[1]

          value = {
            full: version_string,
            major: major_value,
            branch: branch_value
          }

          value[:minor] = minor_value if minor_value
          value[:patchlevel] = patchlevel_value if patchlevel_value

          value
        end
      end
    end
  end
end

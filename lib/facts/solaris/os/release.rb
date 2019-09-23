# frozen_string_literal: true

module Facter
  module Solaris
    class OsRelease
      FACT_NAME = 'os.release'

      def call_the_resolver
        release_value = Facter::Resolvers::SolarisOsReleaseResolver.resolve(:release)
        major_value = Facter::Resolvers::SolarisOsReleaseResolver.resolve(:major)
        minor_value = Facter::Resolvers::SolarisOsReleaseResolver.resolve(:minor)
        os_release = {
            release:release_value,
            major: major_value,
            minor:minor_value
        }
        ResolvedFact.new(FACT_NAME, os_release)
      end
    end
  end
end

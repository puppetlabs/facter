# frozen_string_literal: true

module Facter
  module Solaris
    class OsRelease
      FACT_NAME = 'os.release'

      def call_the_resolver
        full_value = Facter::Resolvers::SolarisRelease.resolve(:full)
        major_value = Facter::Resolvers::SolarisRelease.resolve(:major)
        minor_value = Facter::Resolvers::SolarisRelease.resolve(:minor)
        os_release = {
          full: full_value,
          major: major_value,
          minor: minor_value
        }
        ResolvedFact.new(FACT_NAME, os_release)
      end
    end
  end
end

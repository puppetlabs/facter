# frozen_string_literal: true

module Facter
  module Solaris
    class OsRelease
      FACT_NAME = 'os.release'
      ALIASES = %w[operatingsystemmajrelease operatingsystemrelease].freeze

      def call_the_resolver
        full_value = Facter::Resolvers::SolarisRelease.resolve(:full)
        major_value = Facter::Resolvers::SolarisRelease.resolve(:major)
        minor_value = Facter::Resolvers::SolarisRelease.resolve(:minor)

        [ResolvedFact.new(FACT_NAME, full: full_value, major: major_value, minor: minor_value),
         ResolvedFact.new(ALIASES.first, major_value, :legacy),
         ResolvedFact.new(ALIASES.last, full_value, :legacy)]
      end
    end
  end
end

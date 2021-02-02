# frozen_string_literal: true

module Facts
  module Devuan
    module Os
      module Distro
        class Release
          FACT_NAME = 'os.distro.release'
          ALIASES = %w[lsbdistrelease lsbmajdistrelease lsbminordistrelease].freeze

          def call_the_resolver
            fact_value = Facter::Resolvers::LsbRelease.resolve(:release)
            return Facter::ResolvedFact.new(FACT_NAME, nil) unless fact_value

            release = construct_release(fact_value)

            [Facter::ResolvedFact.new(FACT_NAME, release),
             Facter::ResolvedFact.new(ALIASES[0], fact_value, :legacy),
             Facter::ResolvedFact.new(ALIASES[1], release['major'], :legacy),
             Facter::ResolvedFact.new(ALIASES[2], release['minor'], :legacy)]
          end

          def construct_release(version)
            versions = version.split('.')

            {}.tap do |release|
              release['full'] = version
              release['major'] = versions[0]
              release['minor'] = versions[1] if versions[1]
            end
          end
        end
      end
    end
  end
end

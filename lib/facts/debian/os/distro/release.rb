# frozen_string_literal: true

module Facts
  module Debian
    module Os
      module Distro
        class Release
          FACT_NAME = 'os.distro.release'
          ALIASES = %w[lsbdistrelease lsbmajdistrelease lsbminordistrelease].freeze

          def call_the_resolver
            fact_value = Facter::Resolvers::LsbRelease.resolve(:release)
            return Facter::ResolvedFact.new(FACT_NAME, nil) unless fact_value

            versions = fact_value.split('.')
            release = {
              'full' => fact_value,
              'major' => versions[0],
              'minor' => versions[1]
            }

            [Facter::ResolvedFact.new(FACT_NAME, release),
             Facter::ResolvedFact.new(ALIASES[0], fact_value, :legacy),
             Facter::ResolvedFact.new(ALIASES[1], versions[0], :legacy),
             Facter::ResolvedFact.new(ALIASES[2], versions[1], :legacy)]
          end
        end
      end
    end
  end
end

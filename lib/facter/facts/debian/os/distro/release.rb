# frozen_string_literal: true

module Facts
  module Debian
    module Os
      module Distro
        class Release
          FACT_NAME = 'os.distro.release'
          ALIASES = %w[lsbdistrelease lsbmajdistrelease lsbminordistrelease].freeze

          def call_the_resolver
            fact_value = determine_release_for_os
            return Facter::ResolvedFact.new(FACT_NAME, nil) unless fact_value

            [Facter::ResolvedFact.new(FACT_NAME, fact_value),
             Facter::ResolvedFact.new(ALIASES[0], fact_value['full'], :legacy),
             Facter::ResolvedFact.new(ALIASES[1], fact_value['major'], :legacy),
             Facter::ResolvedFact.new(ALIASES[2], fact_value['minor'], :legacy)]
          end

          private

          def determine_release_for_os
            release = Facter::Resolvers::DebianVersion.resolve(:version)
            return unless release

            versions = release.split('.')
            fact_value = {}
            fact_value['full'] = release
            fact_value['major'] = versions[0]
            fact_value['minor'] = versions[1].gsub(/^0([1-9])/, '\1') if versions[1]
            fact_value
          end
        end
      end
    end
  end
end

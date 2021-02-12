# frozen_string_literal: true

module Facts
  module Sles
    module Os
      module Distro
        class Release
          FACT_NAME = 'os.distro.release'
          ALIASES = %w[lsbdistrelease lsbmajdistrelease lsbminordistrelease].freeze

          def call_the_resolver
            version = Facter::Resolvers::OsRelease.resolve(:version_id)
            fact_value = build_fact_list(version)

            [Facter::ResolvedFact.new(FACT_NAME, fact_value),
             Facter::ResolvedFact.new(ALIASES[0], fact_value[:full], :legacy),
             Facter::ResolvedFact.new(ALIASES[1], fact_value[:major], :legacy),
             Facter::ResolvedFact.new(ALIASES[2], fact_value[:minor], :legacy)]
          end

          def build_fact_list(version)
            if version.include?('.')
              {
                full: version,
                major: version.split('.').first,
                minor: version.split('.').last
              }
            else
              { full: version, major: version, minor: nil }
            end
          end
        end
      end
    end
  end
end

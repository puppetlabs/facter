# frozen_string_literal: true

module Facts
  module Sles
    module Os
      class Release
        FACT_NAME = 'os.release'
        ALIASES = %w[operatingsystemmajrelease operatingsystemrelease].freeze

        def call_the_resolver
          version = Facter::Resolvers::OsRelease.resolve(:version_id)
          fact_value = build_fact_list(version)

          [Facter::ResolvedFact.new(FACT_NAME, fact_value),
           Facter::ResolvedFact.new(ALIASES.first, fact_value[:major], :legacy),
           Facter::ResolvedFact.new(ALIASES.last, fact_value[:full], :legacy)]
        end

        def build_fact_list(version)
          {
            full: "#{version}.0",
            major: version,
            minor: 0
          }
        end
      end
    end
  end
end

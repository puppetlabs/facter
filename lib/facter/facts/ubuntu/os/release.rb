# frozen_string_literal: true

module Facts
  module Ubuntu
    module Os
      class Release
        FACT_NAME = 'os.release'
        ALIASES = %w[operatingsystemmajrelease operatingsystemrelease].freeze

        def call_the_resolver
          version = Facter::Resolvers::OsRelease.resolve(:version_id)

          [Facter::ResolvedFact.new(FACT_NAME, full: version, major: version),
           Facter::ResolvedFact.new(ALIASES.first, version, :legacy),
           Facter::ResolvedFact.new(ALIASES.last, version, :legacy)]
        end
      end
    end
  end
end

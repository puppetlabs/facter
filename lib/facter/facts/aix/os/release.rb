# frozen_string_literal: true

module Facts
  module Aix
    module Os
      class Release
        FACT_NAME = 'os.release'
        ALIASES = %w[operatingsystemmajrelease operatingsystemrelease].freeze

        def call_the_resolver
          fact_value = Facter::Resolvers::Aix::OsLevel.resolve(:build)
          major = fact_value.split('-')[0]

          [Facter::ResolvedFact.new(FACT_NAME, full: fact_value.strip, major: major),
           Facter::ResolvedFact.new(ALIASES.first, major, :legacy),
           Facter::ResolvedFact.new(ALIASES.last, fact_value.strip, :legacy)]
        end
      end
    end
  end
end

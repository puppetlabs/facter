# frozen_string_literal: true

module Facter
  module Aix
    class OsRelease
      FACT_NAME = 'os.release'
      ALIASES = %w[operatingsystemmajrelease operatingsystemrelease].freeze

      def call_the_resolver
        fact_value = Resolvers::OsLevel.resolve(:build)
        major = fact_value.split('-')[0]

        [ResolvedFact.new(FACT_NAME, full: fact_value.strip, major: major),
         ResolvedFact.new(ALIASES.first, major, :legacy),
         ResolvedFact.new(ALIASES.last, fact_value.strip, :legacy)]
      end
    end
  end
end

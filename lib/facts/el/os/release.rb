# frozen_string_literal: true

module Facter
  module El
    class OsRelease
      FACT_NAME = 'os.release'
      ALIASES = %w[operatingsystemmajrelease operatingsystemrelease].freeze

      def call_the_resolver
        version = Resolvers::OsRelease.resolve(:version_id)

        [ResolvedFact.new(FACT_NAME, full: version, major: version),
         ResolvedFact.new(ALIASES.first, version, :legacy),
         ResolvedFact.new(ALIASES.last, version, :legacy)]
      end
    end
  end
end

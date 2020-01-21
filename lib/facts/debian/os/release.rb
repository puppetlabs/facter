# frozen_string_literal: true

module Facter
  module Debian
    class OsRelease
      FACT_NAME = 'os.release'
      ALIASES = %w[operatingsystemmajrelease operatingsystemrelease].freeze

      def call_the_resolver
        fact_value = Resolvers::LsbRelease.resolve(:release)
        versions = fact_value.split('.')
        release = {
          'full' => fact_value,
          'major' => versions[0],
          'minor' => versions[1]
        }

        [ResolvedFact.new(FACT_NAME, release),
         ResolvedFact.new(ALIASES.first, versions[0], :legacy),
         ResolvedFact.new(ALIASES.last, fact_value, :legacy)]
      end
    end
  end
end

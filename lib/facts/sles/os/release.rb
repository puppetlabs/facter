# frozen_string_literal: true

module Facter
  module Sles
    class OsRelease
      FACT_NAME = 'os.release'
      ALIASES = %w[operatingsystemmajrelease operatingsystemrelease].freeze

      def call_the_resolver
        version = Resolvers::OsRelease.resolve(:version_id)
        fact_value = build_fact_list(version)

        [ResolvedFact.new(FACT_NAME, fact_value),
         ResolvedFact.new(ALIASES.first, fact_value[:major], :legacy),
         ResolvedFact.new(ALIASES.last, fact_value[:full], :legacy)]
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

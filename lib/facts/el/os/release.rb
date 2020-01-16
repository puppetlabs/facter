# frozen_string_literal: true

module Facter
  module El
    class OsRelease
      FACT_NAME = 'os.release'

      def call_the_resolver
        version = Resolvers::OsRelease.resolve(:version_id)

        ResolvedFact.new(FACT_NAME, build_fact_list(version))
      end

      def build_fact_list(version)
        {
          full: version,
          major: version
        }
      end
    end
  end
end

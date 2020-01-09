# frozen_string_literal: true

module Facter
  module Windows
    class OsWindowsReleaseID
      FACT_NAME = 'os.windows.release_id'
      ALIASES = 'windows_release_id'

      def call_the_resolver
        fact_value = Resolvers::ProductRelease.resolve(:release_id)

        [ResolvedFact.new(FACT_NAME, fact_value), ResolvedFact.new(ALIASES, fact_value, :legacy)]
      end
    end
  end
end

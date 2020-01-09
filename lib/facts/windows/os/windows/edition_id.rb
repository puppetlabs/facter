# frozen_string_literal: true

module Facter
  module Windows
    class OsWindowsEditionID
      FACT_NAME = 'os.windows.edition_id'
      ALIASES = 'windows_edition_id'

      def call_the_resolver
        fact_value = Resolvers::ProductRelease.resolve(:edition_id)

        [ResolvedFact.new(FACT_NAME, fact_value), ResolvedFact.new(ALIASES, fact_value, :legacy)]
      end
    end
  end
end

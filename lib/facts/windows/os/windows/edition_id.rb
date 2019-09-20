# frozen_string_literal: true

module Facter
  module Windows
    class OsWindowsEditionID
      FACT_NAME = 'os.windows.edition_id'

      def call_the_resolver
        fact_value = Resolvers::ProductReleaseResolver.resolve(:edition_id)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

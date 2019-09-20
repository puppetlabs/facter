# frozen_string_literal: true

module Facter
  module Windows
    class OsWindowsReleaseID
      FACT_NAME = 'os.windows.release_id'

      def call_the_resolver
        fact_value = Resolvers::ProductReleaseResolver.resolve(:release_id)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

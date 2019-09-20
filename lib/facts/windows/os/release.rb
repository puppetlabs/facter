# frozen_string_literal: true

module Facter
  module Windows
    class OsRelease
      FACT_NAME = 'os.release'

      def call_the_resolver
        fact_value = Resolvers::WinOsReleaseResolver.resolve(:full)

        ResolvedFact.new(FACT_NAME, full: fact_value, major: fact_value)
      end
    end
  end
end

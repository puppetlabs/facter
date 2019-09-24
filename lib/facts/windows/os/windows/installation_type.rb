# frozen_string_literal: true

module Facter
  module Windows
    class OsWindowsInstallationType
      FACT_NAME = 'os.windows.installation_type'

      def call_the_resolver
        fact_value = Resolvers::ProductRelease.resolve(:installation_type)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

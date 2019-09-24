# frozen_string_literal: true

module Facter
  module Debian
    class OsArchitecture
      FACT_NAME = 'os.architecture'

      def call_the_resolver
        fact_value = Resolvers::Uname.resolve(:machine)
        fact_value = 'amd64' if fact_value == 'x86_64'

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

# frozen_string_literal: true

module Facter
  module Rhel
    class OsArchitecture
      FACT_NAME = 'os.architecture'

      def call_the_resolver
        fact_value = Resolver::UnameResolver.resolve(:machine)

        Fact.new(FACT_NAME, fact_value)
      end
    end
  end
end

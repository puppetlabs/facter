# frozen_string_literal: true

module Facter
  module Scientific
    class OsRelease
      FACT_NAME = 'os.release'

      def call_the_resolver
        fact_value = UnameResolver.resolve(:release)

        Fact.new(FACT_NAME, fact_value)
      end
    end
  end
end

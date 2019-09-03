# frozen_string_literal: true

module Facter
  module Scientific
    class OsName
      FACT_NAME = 'os.name'

      def call_the_resolver
        fact_value = UnameResolver.resolve(:machine)

        Fact.new(FACT_NAME, fact_value)
      end
    end
  end
end

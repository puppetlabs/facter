# frozen_string_literal: true

module Facter
  module Sles
    class OsHardware
      FACT_NAME = 'os.hardware'

      def call_the_resolver
        fact_value = Resolver::UnameResolver.resolve(:machine)

        Fact.new(FACT_NAME, fact_value)
      end
    end
  end
end

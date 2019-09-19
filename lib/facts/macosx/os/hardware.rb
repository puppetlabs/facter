# frozen_string_literal: true

module Facter
  module Macosx
    class OsHardware
      FACT_NAME = 'os.hardware'

      def call_the_resolver
        fact_value = Resolvers::UnameResolver.resolve(:machine)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

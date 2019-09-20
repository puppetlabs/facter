# frozen_string_literal: true

module Facter
  module Aix
    class OsHardware
      FACT_NAME = 'os.hardware'

      def call_the_resolver
        fact_value = Resolvers::Hardware.resolve(:hardware)

        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

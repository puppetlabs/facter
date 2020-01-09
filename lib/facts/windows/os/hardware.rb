# frozen_string_literal: true

module Facter
  module Windows
    class OsHardware
      FACT_NAME = 'os.hardware'
      ALIASES = 'hardwaremodel'

      def call_the_resolver
        fact_value = Resolvers::HardwareArchitecture.resolve(:hardware)

        [ResolvedFact.new(FACT_NAME, fact_value), ResolvedFact.new(ALIASES, fact_value, :legacy)]
      end
    end
  end
end

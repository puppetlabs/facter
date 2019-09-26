# frozen_string_literal: true

module Facter
  module Solaris
    class OsHardware
      FACT_NAME = 'os.hardware'

      def call_the_resolver
        fact_value = Resolvers::Uname.resolve(:machine)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

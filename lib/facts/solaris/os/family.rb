# frozen_string_literal: true

module Facter
  module Solaris
    class OsFamily
      FACT_NAME = 'os.family'

      def call_the_resolver
        ResolvedFact.new(FACT_NAME, 'Solaris')
      end
    end
  end
end

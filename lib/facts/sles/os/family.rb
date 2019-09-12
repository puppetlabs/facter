# frozen_string_literal: true

module Facter
  module Sles
    class OsFamily
      FACT_NAME = 'os.family'

      def call_the_resolver
        ResolvedFact.new(FACT_NAME, 'RedHat')
      end
    end
  end
end

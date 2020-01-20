# frozen_string_literal: true

module Facter
  module Sles
    class OsFamily
      FACT_NAME = 'os.family'
      ALIASES = 'osfamily'

      def call_the_resolver
        [ResolvedFact.new(FACT_NAME, 'RedHat'), ResolvedFact.new(ALIASES, 'RedHat', :legacy)]
      end
    end
  end
end

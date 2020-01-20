# frozen_string_literal: true

module Facter
  module Solaris
    class OsFamily
      FACT_NAME = 'os.family'
      ALIASES = 'osfamily'

      def call_the_resolver
        [ResolvedFact.new(FACT_NAME, 'Solaris'), ResolvedFact.new(ALIASES, 'Solaris', :legacy)]
      end
    end
  end
end

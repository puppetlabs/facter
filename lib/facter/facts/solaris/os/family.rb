# frozen_string_literal: true

module Facts
  module Solaris
    module Os
      class Family
        FACT_NAME = 'os.family'
        ALIASES = 'osfamily'

        def call_the_resolver
          [Facter::ResolvedFact.new(FACT_NAME, 'Solaris'), Facter::ResolvedFact.new(ALIASES, 'Solaris', :legacy)]
        end
      end
    end
  end
end

# frozen_string_literal: true

module Facts
  module Sles
    module Os
      class Family
        FACT_NAME = 'os.family'
        ALIASES = 'osfamily'

        def call_the_resolver
          [Facter::ResolvedFact.new(FACT_NAME, 'Suse'), Facter::ResolvedFact.new(ALIASES, 'Suse', :legacy)]
        end
      end
    end
  end
end

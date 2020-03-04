# frozen_string_literal: true

module Facts
  module El
    module Os
      class Family
        FACT_NAME = 'os.family'
        ALIASES = 'osfamily'

        def call_the_resolver
          [Facter::ResolvedFact.new(FACT_NAME, 'RedHat'), Facter::ResolvedFact.new(ALIASES, 'RedHat', :legacy)]
        end
      end
    end
  end
end

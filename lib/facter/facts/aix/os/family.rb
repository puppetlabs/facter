# frozen_string_literal: true

module Facts
  module Aix
    module Os
      class Family
        FACT_NAME = 'os.family'
        ALIASES = 'osfamily'

        def call_the_resolver
          fact_value = Facter::Resolvers::Uname.resolve(:kernelname)

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end

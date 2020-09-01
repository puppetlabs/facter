# frozen_string_literal: true

module Facts
  module Windows
    module Os
      class Family
        FACT_NAME = 'os.family'
        ALIASES = 'osfamily'

        def call_the_resolver
          fact_value = Facter::Resolvers::Kernel.resolve(:kernel)

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end

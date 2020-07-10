# frozen_string_literal: true

module Facts
  module Linux
    module Os
      class Architecture
        FACT_NAME = 'os.architecture'
        ALIASES = 'architecture'

        def call_the_resolver
          fact_value = Facter::Resolvers::Uname.resolve(:machine)

          fact_value = 'i386' if fact_value =~ /i[3456]86|pentium/

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end

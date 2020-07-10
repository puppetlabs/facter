# frozen_string_literal: true

module Facts
  module Solaris
    module Os
      class Name
        FACT_NAME = 'os.name'
        ALIASES = 'operatingsystem'

        def call_the_resolver
          value = Facter::Resolvers::Uname.resolve(:kernelname)
          fact_value = value == 'SunOS' ? 'Solaris' : value

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end

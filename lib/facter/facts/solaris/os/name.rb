# frozen_string_literal: true

module Facts
  module Solaris
    module Os
      class Name
        FACT_NAME = 'os.name'
        ALIASES = 'operatingsystem'

        def call_the_resolver
          value = Facter::Resolvers::Uname.resolve(:kernelname)
          version = Facter::Resolvers::Uname.resolve(:kernelversion)
          fact_value = case value
                       when 'SunOS'
                         'Solaris'
                       when /^omnios-/
                         'OmniOS'
                       else
                         value
                       end

          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end
      end
    end
  end
end

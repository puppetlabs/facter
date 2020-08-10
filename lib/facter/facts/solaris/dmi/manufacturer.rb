# frozen_string_literal: true

module Facts
  module Solaris
    module Dmi
      class Manufacturer
        FACT_NAME = 'dmi.manufacturer'
        ALIASES = 'manufacturer'

        def call_the_resolver
          fact_value = if isa == 'i386'
                         Facter::Resolvers::Solaris::Dmi.resolve(:manufacturer)
                       elsif isa == 'sparc'
                         Facter::Resolvers::Solaris::DmiSparc.resolve(:manufacturer)
                       end
          [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
        end

        def isa
          Facter::Resolvers::Uname.resolve(:processor)
        end
      end
    end
  end
end

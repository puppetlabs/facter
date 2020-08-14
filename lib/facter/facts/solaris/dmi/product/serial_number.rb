# frozen_string_literal: true

module Facts
  module Solaris
    module Dmi
      module Product
        class SerialNumber
          FACT_NAME = 'dmi.product.serial_number'
          ALIASES = 'serialnumber'

          def call_the_resolver
            fact_value = if isa == 'i386'
                           Facter::Resolvers::Solaris::Dmi.resolve(:serial_number)
                         elsif isa == 'sparc'
                           Facter::Resolvers::Solaris::DmiSparc.resolve(:serial_number)
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
end

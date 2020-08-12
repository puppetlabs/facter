# frozen_string_literal: true

module Facts
  module Solaris
    module Dmi
      module Product
        class Name
          FACT_NAME = 'dmi.product.name'
          ALIASES = 'productname'

          def call_the_resolver
            fact_value = if isa == 'i386'
                           Facter::Resolvers::Solaris::Dmi.resolve(:product_name)
                         elsif isa == 'sparc'
                           Facter::Resolvers::Solaris::DmiSparc.resolve(:product_name)
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

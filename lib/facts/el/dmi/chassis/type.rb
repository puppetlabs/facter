# frozen_string_literal: true

module Facts
  module El
    module Dmi
      module Chassis
        class Type
          FACT_NAME = 'dmi.chassis.type'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::DmiBios.resolve(:chassis_type)
            Facter::ResolvedFact.new(FACT_NAME, fact_value)
          end
        end
      end
    end
  end
end

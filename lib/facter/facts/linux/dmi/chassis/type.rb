# frozen_string_literal: true

module Facts
  module Linux
    module Dmi
      module Chassis
        class Type
          FACT_NAME = 'dmi.chassis.type'
          ALIASES = 'chassistype'

          def call_the_resolver
            fact_value = Facter::Resolvers::Linux::DmiBios.resolve(:chassis_type)
            [Facter::ResolvedFact.new(FACT_NAME, fact_value), Facter::ResolvedFact.new(ALIASES, fact_value, :legacy)]
          end
        end
      end
    end
  end
end

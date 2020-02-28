# frozen_string_literal: true

module Facter
  module Debian
    class DmiChassisType
      FACT_NAME = 'dmi.chassis.type'

      def call_the_resolver
        fact_value = Resolvers::Linux::DmiBios.resolve(:chassis_type)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

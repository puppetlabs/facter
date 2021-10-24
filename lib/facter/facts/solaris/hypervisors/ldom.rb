# frozen_string_literal: true

module Facts
  module Solaris
    module Hypervisors
      class Ldom
        FACT_NAME = 'hypervisors.ldom'

        def initialize
          @log = Facter::Log.new(self)
        end

        def call_the_resolver
          chassis_serial = Facter::Resolvers::Solaris::Ldom.resolve(:chassis_serial)
          return Facter::ResolvedFact.new(FACT_NAME, nil) if !chassis_serial || chassis_serial.empty?

          fact_value = %i[
            chassis_serial control_domain domain_name
            domain_uuid role_control role_io role_root role_service
          ].map! { |key| [key, Facter::Utils.try_to_bool(Facter::Resolvers::Solaris::Ldom.resolve(key))] }.to_h

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end

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
          fact_value = %i[
            chassis_serial control_domain domain_name
            domain_uuid role_control role_io role_root role_service
          ].map! { |key| [key, Facter::Resolvers::Solaris::Ldom.resolve(key)] }.to_h

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end

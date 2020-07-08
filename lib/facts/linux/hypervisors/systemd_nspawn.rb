# frozen_string_literal: true

module Facts
  module Linux
    module Hypervisors
      class SystemdNspawn
        FACT_NAME = 'hypervisors.systemd_nspawn'

        def call_the_resolver
          fact_value = check_nspawn
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end

        def check_nspawn
          info = Facter::Resolvers::Containers.resolve(:hypervisor)
          info[:systemd_nspawn] if info
        end
      end
    end
  end
end

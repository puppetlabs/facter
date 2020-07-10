# frozen_string_literal: true

module Facts
  module Linux
    module Hypervisors
      class Lxc
        FACT_NAME = 'hypervisors.lxc'

        def call_the_resolver
          fact_value = check_lxc
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end

        def check_lxc
          info = Facter::Resolvers::Containers.resolve(:hypervisor)
          info[:lxc] if info
        end
      end
    end
  end
end

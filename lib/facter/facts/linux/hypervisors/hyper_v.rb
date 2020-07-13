# frozen_string_literal: true

module Facts
  module Linux
    module Hypervisors
      class HyperV
        FACT_NAME = 'hypervisors.hyperv'

        def call_the_resolver
          fact_value = check_hyper_v
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end

        def check_hyper_v
          manufacturer = Facter::Resolvers::Linux::DmiBios.resolve(:sys_vendor)
          product_name = Facter::Resolvers::Linux::DmiBios.resolve(:product_name)

          return {} if manufacturer =~ /Microsoft/ || product_name == 'Virtual Machine'

          nil
        end
      end
    end
  end
end

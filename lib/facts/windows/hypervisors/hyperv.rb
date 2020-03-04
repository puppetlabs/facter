# frozen_string_literal: true

module Facts
  module Windows
    module Hypervisors
      class Hyperv
        FACT_NAME = 'hypervisors.hyperv'

        def call_the_resolver
          fact_value = {} if hyperv?

          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end

        private

        def hyperv?
          Facter::Resolvers::Virtualization.resolve(:virtual) == 'hyperv' ||
            Facter::Resolvers::DMIBios.resolve(:manufacturer).include?('Microsoft')
        end
      end
    end
  end
end

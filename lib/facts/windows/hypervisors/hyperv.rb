# frozen_string_literal: true

module Facter
  module Windows
    class HypervisorsHyperv
      FACT_NAME = 'hypervisors.hyperv'

      def call_the_resolver
        fact_value = {} if hyperv?

        ResolvedFact.new(FACT_NAME, fact_value)
      end

      private

      def hyperv?
        Resolvers::Virtualization.resolve(:virtual) == 'hyperv' ||
          Resolvers::DMIBios.resolve(:manufacturer).include?('Microsoft')
      end
    end
  end
end

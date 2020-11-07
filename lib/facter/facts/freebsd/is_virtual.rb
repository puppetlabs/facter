# frozen_string_literal: true

module Facts
  module Freebsd
    class IsVirtual
      FACT_NAME = 'is_virtual'

      def initialize
        @virtual = Facter::VirtualDetector.new
      end

      def call_the_resolver
        fact_value = @virtual.platform

        Facter::ResolvedFact.new(FACT_NAME, check_if_virtual(fact_value))
      end

      private

      def check_if_virtual(found_vm)
        Facter::FactsUtils::PHYSICAL_HYPERVISORS.count(found_vm).zero?.to_s
      end
    end
  end
end

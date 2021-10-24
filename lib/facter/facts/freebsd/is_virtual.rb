# frozen_string_literal: true

module Facts
  module Freebsd
    class IsVirtual
      FACT_NAME = 'is_virtual'

      def call_the_resolver
        fact_value = Facter::Util::Facts::Posix::VirtualDetector.platform

        Facter::ResolvedFact.new(FACT_NAME, check_if_virtual(fact_value))
      end

      private

      def check_if_virtual(found_vm)
        Facter::Util::Facts::PHYSICAL_HYPERVISORS.count(found_vm).zero?
      end
    end
  end
end

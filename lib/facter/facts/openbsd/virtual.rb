# frozen_string_literal: true

module Facts
  module Openbsd
    class Virtual
      FACT_NAME = 'virtual'

      def call_the_resolver
        fact_value = Facter::Util::Facts::Posix::VirtualDetector.platform

        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

# frozen_string_literal: true

module Facts
  module Linux
    class Virtual
      FACT_NAME = 'virtual'

      def initialize
        @log = Facter::Log.new(self)
      end

      def call_the_resolver
        @log.debug('Linux Virtual Resolver')
        fact_value = Facter::Util::Facts::Posix::VirtualDetector.platform
        @log.debug("Fact value is: #{fact_value}")

        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

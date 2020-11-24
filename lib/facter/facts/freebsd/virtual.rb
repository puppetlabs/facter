# frozen_string_literal: true

module Facts
  module Freebsd
    class Virtual
      FACT_NAME = 'virtual'

      def initialize
        @log = Facter::Log.new(self)
        @virtual = Facter::VirtualDetector.new
      end

      def call_the_resolver
        @log.debug('FreeBSD Virtual Resolver')
        fact_value = @virtual.platform
        @log.debug("Fact value is: #{fact_value}")

        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

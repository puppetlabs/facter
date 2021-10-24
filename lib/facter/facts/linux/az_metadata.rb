# frozen_string_literal: true

module Facts
  module Linux
    class AzMetadata
      FACT_NAME = 'az_metadata'

      def call_the_resolver
        return Facter::ResolvedFact.new(FACT_NAME, nil) unless azure_hypervisor?

        fact_value = Facter::Resolvers::Az.resolve(:metadata)

        Facter::ResolvedFact.new(FACT_NAME, fact_value&.empty? ? nil : fact_value)
      end

      private

      def azure_hypervisor?
        Facter::Util::Facts::Posix::VirtualDetector.platform == 'hyperv'
      end
    end
  end
end

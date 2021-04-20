# frozen_string_literal: true

module Facts
  module Windows
    class AzMetadata
      FACT_NAME = 'az_metadata'

      def call_the_resolver
        return Facter::ResolvedFact.new(FACT_NAME, nil) unless azure_hypervisor?

        fact_value = Facter::Resolvers::Az.resolve(:metadata)

        Facter::ResolvedFact.new(FACT_NAME, fact_value&.empty? ? nil : fact_value)
      end

      private

      def azure_hypervisor?
        Facter::Resolvers::Windows::Virtualization.resolve(:virtual) == 'hyperv'
      end
    end
  end
end

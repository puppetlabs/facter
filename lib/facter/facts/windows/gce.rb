# frozen_string_literal: true

module Facts
  module Windows
    class Gce
      FACT_NAME = 'gce'

      def call_the_resolver
        virtualization = Facter::Resolvers::Virtualization.resolve(:virtual)

        fact_value = virtualization&.include?('gce') ? Facter::Resolvers::Gce.resolve(:metadata) : nil
        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

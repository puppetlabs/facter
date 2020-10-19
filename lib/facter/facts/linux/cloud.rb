# frozen_string_literal: true

module Facts
  module Linux
    class Cloud
      FACT_NAME = 'cloud'

      def call_the_resolver
        cloud_provider = Facter::Resolvers::Cloud.resolve(:cloud_provider)

        Facter::ResolvedFact.new(FACT_NAME, cloud_provider)
      end
    end
  end
end

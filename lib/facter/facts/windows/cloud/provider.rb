# frozen_string_literal: true

module Facts
  module Windows
    module Cloud
      class Provider
        FACT_NAME = 'cloud.provider'

        def call_the_resolver
          az_metadata = Facter::Resolvers::Az.resolve(:metadata)

          Facter::ResolvedFact.new(FACT_NAME, az_metadata&.empty? ? nil : 'azure')
        end
      end
    end
  end
end

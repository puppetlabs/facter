# frozen_string_literal: true

module Facts
  module Windows
    module Cloud
      class Provider
        FACT_NAME = 'cloud.provider'

        def call_the_resolver
          virtual = Facter::Resolvers::Virtualization.resolve(:virtual)
          provider = case virtual
                     when 'hyperv'
                       'azure' unless Facter::Resolvers::Az.resolve(:metadata).empty?
                     end

          Facter::ResolvedFact.new(FACT_NAME, provider)
        end
      end
    end
  end
end

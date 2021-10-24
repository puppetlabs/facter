# frozen_string_literal: true

module Facts
  module Linux
    module Processors
      class Cores
        FACT_NAME = 'processors.cores'

        def call_the_resolver
          fact_value = Facter::Resolvers::Linux::Lscpu.resolve(:cores_per_socket)
          Facter::ResolvedFact.new(FACT_NAME, fact_value)
        end
      end
    end
  end
end

# frozen_string_literal: true

module Facts
  module Aix
    module Hypervisors
      class Lpar
        FACT_NAME = 'hypervisors.lpar'

        def call_the_resolver
          lpar_partition_number = Facter::Resolvers::Lpar.resolve(:lpar_partition_number)
          return Facter::ResolvedFact.new(FACT_NAME, nil) unless lpar_partition_number&.positive?

          Facter::ResolvedFact.new(FACT_NAME,
                                   partition_number: lpar_partition_number,
                                   partition_name: Facter::Resolvers::Lpar.resolve(:lpar_partition_name))
        end
      end
    end
  end
end

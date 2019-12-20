# frozen_string_literal: true

module Facter
  module Aix
    class HypervisorsLpar
      FACT_NAME = 'hypervisors.lpar'

      def call_the_resolver
        lpar_partition_number = Resolvers::Lpar.resolve(:lpar_partition_number)
        return ResolvedFact.new(FACT_NAME, nil) unless lpar_partition_number&.positive?

        ResolvedFact.new(FACT_NAME,
                         partition_number: lpar_partition_number,
                         partition_name: Resolvers::Lpar.resolve(:lpar_partition_name))
      end
    end
  end
end

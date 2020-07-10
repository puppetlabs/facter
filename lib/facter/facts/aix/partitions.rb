# frozen_string_literal: true

module Facts
  module Aix
    class Partitions
      FACT_NAME = 'partitions'

      def call_the_resolver
        partitions = Facter::Resolvers::Aix::Partitions.resolve(:partitions)

        Facter::ResolvedFact.new(FACT_NAME, partitions.empty? ? nil : partitions)
      end
    end
  end
end

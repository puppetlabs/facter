# frozen_string_literal: true

module Facts
  module Freebsd
    class Partitions
      FACT_NAME = 'partitions'

      def call_the_resolver
        partitions = Facter::Resolvers::Freebsd::Geom.resolve(:partitions)

        Facter::ResolvedFact.new(FACT_NAME, partitions)
      end
    end
  end
end

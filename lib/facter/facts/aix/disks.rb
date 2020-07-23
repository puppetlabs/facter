# frozen_string_literal: true

module Facts
  module Aix
    class Disks
      FACT_NAME = 'disks'

      def call_the_resolver
        disks = Facter::Resolvers::Aix::Disks.resolve(:disks)

        disks = disks&.empty? ? nil : disks

        Facter::ResolvedFact.new(FACT_NAME, disks)
      end
    end
  end
end

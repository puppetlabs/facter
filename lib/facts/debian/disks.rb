# frozen_string_literal: true

module Facts
  module Debian
    class Disks
      FACT_NAME = 'disks'

      def call_the_resolver
        disks = Facter::Resolvers::Linux::Disk.resolve(:disks)

        Facter::ResolvedFact.new(FACT_NAME, disks)
      end
    end
  end
end

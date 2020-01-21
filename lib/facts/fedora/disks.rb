# frozen_string_literal: true

module Facter
  module Fedora
    class Disks
      FACT_NAME = 'disks'

      def call_the_resolver
        disks = Resolvers::Linux::Disk.resolve(:disks)

        ResolvedFact.new(FACT_NAME, disks)
      end
    end
  end
end

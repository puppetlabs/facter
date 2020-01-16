# frozen_string_literal: true

module Facter
  module El
    class DiskSr0SizeBytes
      FACT_NAME = 'disk.sr0.size_bytes'

      def call_the_resolver
        fact_value = Resolvers::Linux::Disk.resolve(:sr0_size)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

# frozen_string_literal: true

module Facter
  module El
    class DiskSdaSizeBytes
      FACT_NAME = 'disk.sda.size_bytes'

      def call_the_resolver
        fact_value = Resolvers::Linux::Disk.resolve(:sda_size)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

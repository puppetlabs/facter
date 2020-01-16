# frozen_string_literal: true

module Facter
  module El
    class DiskSr0Size
      FACT_NAME = 'disk.sr0.size'

      def call_the_resolver
        fact_value = Resolvers::Linux::Disk.resolve(:sr0_size)
        fact_value = BytesToHumanReadable.convert(fact_value)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

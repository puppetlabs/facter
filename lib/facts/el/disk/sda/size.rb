# frozen_string_literal: true

module Facter
  module El
    class DiskSdaSize
      FACT_NAME = 'disk.sda.size'

      def call_the_resolver
        fact_value = Resolvers::Linux::Disk.resolve(:sda_size)
        fact_value = BytesToHumanReadable.convert(fact_value)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

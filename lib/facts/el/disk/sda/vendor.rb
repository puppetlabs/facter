# frozen_string_literal: true

module Facter
  module El
    class DiskSdaVendor
      FACT_NAME = 'disk.sda.vendor'

      def call_the_resolver
        fact_value = Resolvers::Linux::Disk.resolve(:sda_vendor)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

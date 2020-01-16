# frozen_string_literal: true

module Facter
  module El
    class DiskSr0Vendor
      FACT_NAME = 'disk.sr0.vendor'

      def call_the_resolver
        fact_value = Resolvers::Linux::Disk.resolve(:sr0_vendor)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

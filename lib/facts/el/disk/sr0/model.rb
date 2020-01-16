# frozen_string_literal: true

module Facter
  module El
    class DiskSr0Model
      FACT_NAME = 'disk.sr0.model'

      def call_the_resolver
        fact_value = Resolvers::Linux::Disk.resolve(:sr0_model)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

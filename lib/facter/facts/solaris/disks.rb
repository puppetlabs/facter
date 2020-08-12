# frozen_string_literal: true

module Facts
  module Solaris
    class Disks
      FACT_NAME = 'disks'

      def call_the_resolver
        fact_value = Facter::Resolvers::Solaris::Disks.resolve(:disks)
        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

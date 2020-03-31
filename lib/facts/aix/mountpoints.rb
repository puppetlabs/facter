# frozen_string_literal: true

module Facts
  module Aix
    class Mountpoints
      FACT_NAME = 'mountpoints'

      def call_the_resolver
        mountpoints = Facter::Resolvers::Aix::Mountpoints.resolve(:mountpoints)

        Facter::ResolvedFact.new(FACT_NAME, mountpoints)
      end
    end
  end
end

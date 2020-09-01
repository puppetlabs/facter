# frozen_string_literal: true

module Facts
  module Macosx
    class Mountpoints
      FACT_NAME = 'mountpoints'

      def call_the_resolver
        mountpoints = Facter::Resolvers::Macosx::Mountpoints.resolve(FACT_NAME.to_sym)
        return Facter::ResolvedFact.new(FACT_NAME, nil) unless mountpoints

        Facter::ResolvedFact.new(FACT_NAME, mountpoints)
      end
    end
  end
end

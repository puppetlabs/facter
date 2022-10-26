# frozen_string_literal: true

module Facts
  module Openbsd
    class Mountpoints
      FACT_NAME = 'mountpoints'

      def call_the_resolver
        mountpoints = Facter::Resolvers::Openbsd::Mountpoints.resolve(FACT_NAME.to_sym)
        return Facter::ResolvedFact.new(FACT_NAME, nil) unless mountpoints

        fact = {}
        mountpoints.each do |path, mnt|
          fact[path.to_sym] = mnt.reject { |k| k == :path }
        end

        Facter::ResolvedFact.new(FACT_NAME, fact)
      end
    end
  end
end

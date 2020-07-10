# frozen_string_literal: true

module Facts
  module Bsd
    class Kernelmajversion
      FACT_NAME = 'kernelmajversion'

      def call_the_resolver
        full_version = Facter::Resolvers::Uname.resolve(:kernelrelease)
        versions_split = full_version.split('.')
        major_version = versions_split[0]
        Facter::ResolvedFact.new(FACT_NAME, major_version)
      end
    end
  end
end

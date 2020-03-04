# frozen_string_literal: true

module Facts
  module Macosx
    class Kernelmajversion
      FACT_NAME = 'kernelmajversion'

      def call_the_resolver
        kernel_major_version = Facter::Resolvers::Uname.resolve(:kernelrelease).match(/[0-9]+\.[0-9]+/).to_s

        Facter::ResolvedFact.new(FACT_NAME, kernel_major_version)
      end
    end
  end
end

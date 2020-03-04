# frozen_string_literal: true

module Facts
  module Macosx
    class Kernelversion
      FACT_NAME = 'kernelversion'

      def call_the_resolver
        kernel_version = Facter::Resolvers::Uname.resolve(:kernelrelease)
        Facter::ResolvedFact.new(FACT_NAME, kernel_version)
      end
    end
  end
end

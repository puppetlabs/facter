# frozen_string_literal: true

module Facter
  module Macosx
    class Kernelversion
      FACT_NAME = 'kernelversion'

      def call_the_resolver
        kernel_version = Resolvers::Uname.resolve(:kernelrelease)
        ResolvedFact.new(FACT_NAME, kernel_version)
      end
    end
  end
end

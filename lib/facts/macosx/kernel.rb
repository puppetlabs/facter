# frozen_string_literal: true

module Facter
  module Macosx
    class Kernel
      FACT_NAME = 'kernel'

      def call_the_resolver
        fact_value = Resolvers::Uname.resolve(:kernelname)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

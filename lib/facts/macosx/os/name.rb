# frozen_string_literal: true

module Facter
  module Macosx
    class OsName
      FACT_NAME = 'os.name'
      @log = Facter::Log.new(self)

      def call_the_resolver
        fact_value = Resolvers::Uname.resolve(:kernelname)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

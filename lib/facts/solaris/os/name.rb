# frozen_string_literal: true

module Facter
  module Solaris
    class OsName
      FACT_NAME = 'os.name'

      def call_the_resolver
        value = Resolvers::UnameResolver.resolve(:kernelname)
        fact_value = value == 'SunOS' ? 'Solaris' : value
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

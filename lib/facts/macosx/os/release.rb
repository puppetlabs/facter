# frozen_string_literal: true

module Facter
  module Macosx
    class OsRelease
      FACT_NAME = 'os.release'

      def call_the_resolver
        fact_value = Resolvers::Uname.resolve(:kernelrelease)
        release_strings = fact_value.split('.')
        ResolvedFact.new(FACT_NAME,
                         full: fact_value,
                         major: release_strings[0],
                         minor: release_strings[1])
      end
    end
  end
end

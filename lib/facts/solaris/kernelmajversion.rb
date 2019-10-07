# frozen_string_literal: true

module Facter
  module Solaris
    class Kernelmajversion
      FACT_NAME = 'kernelmajversion'

      def call_the_resolver
        full_version = Resolvers::Uname.resolve(:kernelversion)
        versions_split = full_version.split('.')
        major_version = versions_split.length > 1 ? versions_split[0] + '.' + versions_split[1] : versions_split[0]
        ResolvedFact.new(FACT_NAME, major_version)
      end
    end
  end
end

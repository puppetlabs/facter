# frozen_string_literal: true

module Facter
  module Macosx
    class Filesystems
      FACT_NAME = 'filesystems'

      def call_the_resolver
        fact_value = Resolvers::Macosx::Filesystems.resolve(:macosx_filesystems)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

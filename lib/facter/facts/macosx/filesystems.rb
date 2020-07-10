# frozen_string_literal: true

module Facts
  module Macosx
    class Filesystems
      FACT_NAME = 'filesystems'

      def call_the_resolver
        fact_value = Facter::Resolvers::Macosx::Filesystems.resolve(:macosx_filesystems)
        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

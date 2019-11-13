# frozen_string_literal: true

module Facter
  module Fedora
    class Filesystem
      FACT_NAME = 'filesystem'

      def call_the_resolver
        fact_value = Resolvers::Linux::Filesystems.resolve(:systems)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

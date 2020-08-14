# frozen_string_literal: true

module Facts
  module Solaris
    class ZfsVersion
      FACT_NAME = 'zfs_version'

      def call_the_resolver
        fact_value = Facter::Resolvers::ZFS.resolve(:zfs_version)
        Facter::ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

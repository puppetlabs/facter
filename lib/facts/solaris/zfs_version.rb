# frozen_string_literal: true

module Facter
  module Solaris
    class ZFSVersion
      FACT_NAME = 'zfs_version'

      def call_the_resolver
        fact_value = Resolvers::Solaris::ZFS.resolve(:zfs_version)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

# frozen_string_literal: true

module Facter
  module Solaris
    class ZFSFeatureNumbers
      FACT_NAME = 'zfs_featurenumbers'

      def call_the_resolver
        fact_value = Resolvers::Solaris::ZFS.resolve(:zfs_featurenumbers)
        ResolvedFact.new(FACT_NAME, fact_value)
      end
    end
  end
end

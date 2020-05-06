# frozen_string_literal: true

module Facter
  module Resolvers
    module Solaris
      class ZFS < BaseResolver
        @semaphore = Mutex.new
        @fact_list ||= {}
        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { zfs_fact(fact_name) }
          end

          def zfs_fact(fact_name)
            build_zfs_facts
            @fact_list[fact_name]
          end

          def build_zfs_facts
            output = Facter::Core::Execution.execute('zfs upgrade -v', logger: log)
            features_list = output.scan(/^\s+(\d+)/).flatten

            return if features_list.empty?

            @fact_list[:zfs_featurenumbers] = features_list.join(',')
            @fact_list[:zfs_version] = features_list.last
          end
        end
      end
    end
  end
end

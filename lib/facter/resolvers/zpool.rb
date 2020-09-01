# frozen_string_literal: true

module Facter
  module Resolvers
    class Zpool < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}
      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { zpool_fact(fact_name) }
        end

        def zpool_fact(fact_name)
          build_zpool_facts
          @fact_list[fact_name]
        end

        def build_zpool_facts
          output = Facter::Core::Execution.execute('zpool upgrade -v', logger: log)
          features_list = output.scan(/^\s+(\d+)/).flatten
          features_flags = output.scan(/^([a-z0-9_]+)[[:blank:]]*(\(read-only compatible\))?$/).map(&:first)

          return if features_list.empty?

          @fact_list[:zpool_featurenumbers] = features_list.join(',')
          @fact_list[:zpool_featureflags] = features_flags.join(',')
          @fact_list[:zpool_version] = features_flags.any? ? '5000' : features_list.last
        end
      end
    end
  end
end

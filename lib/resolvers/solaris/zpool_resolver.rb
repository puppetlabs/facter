# frozen_string_literal: true

module Facter
  module Resolvers
    module Solaris
      class ZPool < BaseResolver
        @log = Facter::Log.new(self)
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
            output, _status = Open3.capture2('zpool upgrade -v')
            features_list = output.scan(/^\s+(\d+)/).flatten

            return if features_list.empty?

            @fact_list[:zpool_featurenumbers] = features_list.join(',')
            @fact_list[:zpool_version] = features_list.last
          end
        end
      end
    end
  end
end

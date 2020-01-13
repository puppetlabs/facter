# frozen_string_literal: true

module Facter
  module Resolvers
    class Agent < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_agent_version }
        end

        def read_agent_version
          version_file = ::File.join(ROOT_DIR, 'lib/puppet/VERSION')
          @fact_list[:aio_agent_version] = ::File.read(version_file)
        end
      end
    end
  end
end

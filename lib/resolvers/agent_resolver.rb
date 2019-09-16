# frozen_string_literal: true

module Facter
  module Resolver
    class AgentResolver < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            result || read_agent_version
          end
        end

        private

        def read_agent_version
          version_file = ::File.join(ROOT_DIR, 'lib/puppet/VERSION')
          @fact_list[:aio_agent_version] = ::File.read(version_file)
        end
      end
    end
  end
end

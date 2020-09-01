# frozen_string_literal: true

module Facter
  module Resolvers
    class AioAgentVersion < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_agent_version }
        end

        def read_agent_version
          aio_agent_version = Util::FileHelper.safe_read('/opt/puppetlabs/puppet/VERSION', nil)&.chomp
          aio_agent_version = aio_agent_version&.match(/^\d+\.\d+\.\d+(\.\d+){0,2}/)&.to_s
          @fact_list[:aio_agent_version] = aio_agent_version
        end
      end
    end
  end
end

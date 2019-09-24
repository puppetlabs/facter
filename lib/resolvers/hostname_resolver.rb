# frozen_string_literal: true

module Facter
  module Resolvers
    class Hostname < BaseResolver
      @log = Facter::Log.new
      @semaphore = Mutex.new
      @fact_list ||= {}
      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || retrieve_hostname
          end
        end

        private

        def retrieve_hostname
          output, _status = Open3.capture2('hostname')
          @fact_list[:hostname] = output&.strip
        end
      end
    end
  end
end

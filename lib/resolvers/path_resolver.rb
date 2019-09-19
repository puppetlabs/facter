# frozen_string_literal: true

module Facter
  module Resolvers
    class PathResolver < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || read_path_from_env
          end
        end

        private

        def read_path_from_env
          @fact_list[:path] = ENV['PATH']
        end
      end
    end
  end
end

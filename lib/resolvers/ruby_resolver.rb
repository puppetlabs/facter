# frozen_string_literal: true

module Facter
  module Resolvers
    class Ruby < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || retrieve_ruby_information(fact_name)
          end
        end

        private

        def retrieve_ruby_information(fact_name)
          @fact_list[:sitedir] = RbConfig::CONFIG['sitelibdir']
          @fact_list[:platform] = RUBY_PLATFORM
          @fact_list[:version] = RUBY_VERSION
          @fact_list[fact_name]
        end
      end
    end
  end
end

# frozen_string_literal: true

module Facter
  module Resolvers
    class TimezoneResolver < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || determine_timezone
          end
        end

        private

        def determine_timezone
          @fact_list[:timezone] = Time.now.localtime.strftime('%Z')
        end
      end
    end
  end
end

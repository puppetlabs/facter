# frozen_string_literal: true

module Facter
  module Resolver
    class FacterversionResolver < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            result || read_version_file
          end
        end

        private

        def read_version_file
          version_file = ::File.join(ROOT_DIR, 'VERSION')
          @fact_list[:facterversion] = ::File.read(version_file)
        end
      end
    end
  end
end

# frozen_string_literal: true

module Facter
  module Resolvers
    class Augeas < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_augeas_version(fact_name) }
        end

        def read_augeas_version(fact_name)
          output, _status = Open3.capture2('augparse --version 2>&1')
          @fact_list[:augeas_version] = Regexp.last_match(1) if output =~ /^augparse (\d+\.\d+\.\d+)/
          @fact_list[fact_name]
        end
      end
    end
  end
end

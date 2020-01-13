# frozen_string_literal: true

module Facter
  module Resolvers
    class OsLevel < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_oslevel(fact_name) }
        end

        def read_oslevel(fact_name)
          output, _status = Open3.capture2('/usr/bin/oslevel -s 2>/dev/null')
          @fact_list[:build] = output
          @fact_list[:kernel] = 'AIX'

          @fact_list[fact_name]
        end
      end
    end
  end
end

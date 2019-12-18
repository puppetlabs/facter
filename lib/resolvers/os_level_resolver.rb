# frozen_string_literal: true

module Facter
  module Resolvers
    class OsLevel < BaseResolver
      # build

      class << self
        @@semaphore = Mutex.new
        @@fact_list ||= {}

        def resolve(fact_name)
          @@semaphore.synchronize do
            result ||= @@fact_list[fact_name]
            subscribe_to_manager
            result || read_oslevel(fact_name)
          end
        end

        def read_oslevel(fact_name)
          output, _status = Open3.capture2('/usr/bin/oslevel -s 2>/dev/null')
          @@fact_list[:build] = output
          @@fact_list[:kernel] = 'AIX'

          @@fact_list[fact_name]
        end
      end
    end
  end
end

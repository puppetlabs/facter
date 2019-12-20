# frozen_string_literal: true

module Facter
  module Resolvers
    class Wpar < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || read_wpar(fact_name)
          end
        end

        def read_wpar(fact_name)
          lpar_cmd = '/usr/bin/lparstat -W 2>/dev/null'
          output, status = Open3.capture2(lpar_cmd)
          return nil unless status.success?

          output.each_line do |line|
            populate_wpar_data(line.split(':').map(&:strip))
          end
          @fact_list[fact_name]
        end

        private

        def populate_wpar_data(key_value)
          @fact_list[:wpar_key]              = key_value[1].to_i if key_value[0] == 'WPAR Key'
          @fact_list[:wpar_configured_id]    = key_value[1].to_i if key_value[0] == 'WPAR Configured ID'
        end
      end
    end
  end
end

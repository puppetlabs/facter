# frozen_string_literal: true

module Facter
  module Resolvers
    class Wpar < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { read_wpar(fact_name) }
        end

        def read_wpar(fact_name)
          output = Facter::Core::Execution.execute('/usr/bin/lparstat -W', logger: log)

          return if output.empty?

          output.each_line do |line|
            populate_wpar_data(line.split(':').map(&:strip))
          end
          @fact_list[fact_name]
        end

        def populate_wpar_data(key_value)
          @fact_list[:wpar_key]              = key_value[1].to_i if key_value[0] == 'WPAR Key'
          @fact_list[:wpar_configured_id]    = key_value[1].to_i if key_value[0] == 'WPAR Configured ID'
        end
      end
    end
  end
end

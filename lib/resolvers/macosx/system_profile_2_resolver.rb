
# frozen_string_literal: true

module Facter
  module Resolvers
    class SystemProfiler_2 < BaseResolver

      @semaphore = Mutex.new
      @fact_list = {}

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { retrieve_system_profiler(fact_name) }
        end

        def retrieve_system_profiler(fact_name)
          @fact_list ||= {}

          log.debug 'Executing command: system_profiler SPSoftwareDataType SPHardwareDataType'
          output = Facter::Core::Execution.execute(
            'system_profiler SPEthernetDataType', logger: log
          ).force_encoding('UTF-8')
          @fact_list = output.scan(/.*:[ ].*$/).map { |e| e.strip.match(/(.*?): (.*)/).captures }.to_h
          normalize_factlist

          @fact_list[fact_name]
        end

        def normalize_factlist
          @fact_list = @fact_list.map do |k, v|
            [k.downcase.tr(' ', '_').delete("\(\)").to_sym, v]
          end.to_h
        end
      end
    end
  end
end

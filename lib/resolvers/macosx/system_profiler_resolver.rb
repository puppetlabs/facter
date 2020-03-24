# frozen_string_literal: true

module Facter
  module Resolvers
    class SystemProfiler < BaseResolver
      # model_name
      # model_identifier
      # processor_name
      # processor_speed
      # number_of_processors
      # total_number_of_cores
      # l2_cache_per_core
      # l3_cache
      # hyper-threading_technology
      # memory
      # boot_rom_version
      # serial_number_system
      # hardware_uuid
      # activation_lock_status
      # system_version
      # kernel_version
      # boot_volume
      # boot_mode
      # computer_name
      # user_name
      # secure_virtual_memory
      # system_integrity_protection
      # time_since_boot
      # smc_version_system

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
          output, _status = Open3.capture2('system_profiler SPHardwareDataType SPSoftwareDataType')
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

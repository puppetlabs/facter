# frozen_string_literal: true

module Facter
  module Resolvers
    class SystemProfiler < BaseResolver
      sp_hardware_data_type = %i[model_name model_identifier processor_speed number_of_processors processor_name
                                 total_number_of_cores l2_cache_per_core l3_cache memory boot_rom_version
                                 smc_version_system serial_number_system hardware_uuid, hyper-threading_technology,
                                 activation_lock_status]

      sp_software_data_type = %i[system_version kernel_version boot_volume boot_mode computer_name
                                 user_name secure_virtual_memory system_integrity_protection time_since_boot]

      sp_ethernet_data_type = %i[type bus vendor_id device_id subsystem_vendor_id
                                 subsystem_id revision_id bsd_name kext_name location version]

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
            'system_profiler SPHardwareDataType SPSoftwareDataType', logger: log
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

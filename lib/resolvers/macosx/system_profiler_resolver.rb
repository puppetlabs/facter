# frozen_string_literal: true

module Facter
  module Resolvers
    module Macosx
      class SystemProfiler < BaseResolver
        SP_HARDWARE_DATA_TYPE = %i[model_name model_identifier processor_speed number_of_processors processor_name
                                   total_number_of_cores l2_cache_per_core l3_cache memory boot_rom_version
                                   smc_version_system serial_number_system hardware_uuid hyper-threading_technology
                                   activation_lock_status].freeze

        SP_SOFTWARE_DATA_TYPE = %i[system_version kernel_version boot_volume boot_mode computer_name
                                   user_name secure_virtual_memory system_integrity_protection time_since_boot].freeze

        SP_ETHERNET_DATA_TYPE = %i[type bus vendor_id device_id subsystem_vendor_id
                                   subsystem_id revision_id bsd_name kext_name location version].freeze

        @semaphore = Mutex.new
        @fact_list = {}

        class << self
          private

          def post_resolve(fact_name)
            @fact_list.fetch(fact_name) { retrieve_system_profiler(fact_name) }
          end

          def retrieve_system_profiler(fact_name)
            @fact_list ||= {}

            case fact_name
            when *SP_HARDWARE_DATA_TYPE
              @fact_list.merge!(SystemProfileExecutor.execute('SPHardwareDataType'))
            when *SP_SOFTWARE_DATA_TYPE
              @fact_list.merge!(SystemProfileExecutor.execute('SPSoftwareDataType'))
            when *SP_ETHERNET_DATA_TYPE
              @fact_list.merge!(SystemProfileExecutor.execute('SPEthernetDataType'))
            end

            @fact_list[fact_name]
          end
        end
      end
    end
  end
end

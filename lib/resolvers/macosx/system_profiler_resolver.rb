# frozen_string_literal: true

module Facter
  module Resolvers
    class SystemProfiler < BaseResolver
      @log = Facter::Log.new(self)
      @semaphore = Mutex.new
      @fact_list ||= {}
      NAME_HASH = { boot_rom_version: 'Boot ROM Version',
                    cores: 'Total Number of Cores',
                    hardware_uuid: 'Hardware UUID',
                    l2_cache_per_core: 'L2 Cache (per Core)',
                    l3_cache: 'L3 Cache',
                    memory: 'Memory',
                    model_identifier: 'Model Identifier',
                    model_name: 'Model Name',
                    processor_name: 'Processor Name',
                    processor_speed: 'Processor Speed',
                    processors: 'Number of Processors',
                    serial_number: 'Serial Number (system)',
                    smc_version: 'SMC Version (system)',
                    boot_mode: 'Boot Mode',
                    boot_volume: 'Boot Volume',
                    computer_name: 'Computer Name',
                    kernel_version: 'Kernel Version',
                    secure_virtual_memory: 'Secure Virtual Memory',
                    system_version: 'System Version',
                    uptime: 'Time since boot',
                    username: 'User Name' }.freeze

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { retrieve_system_profiler(fact_name) }
        end

        def retrieve_system_profiler(fact_name)
          @log.debug 'Executing command: system_profiler SPSoftwareDataType SPHardwareDataType'
          output, _status = Open3.capture2('system_profiler SPHardwareDataType SPSoftwareDataType')
          system_profiler = output.scan(/.*:[ ].*$/).map { |e| e.strip.match(/(.*?): (.*)/).captures }.to_h
          NAME_HASH.each { |key, v| @fact_list[key] = system_profiler[v] }
          @fact_list[fact_name]
        end
      end
    end
  end
end

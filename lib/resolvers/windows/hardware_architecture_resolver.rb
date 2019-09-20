# frozen_string_literal: true

module Facter
  module Resolvers
    class HardwareArchitectureResolver < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}
      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || read_hardware_information(fact_name)
          end
        end

        private

        def read_hardware_information(fact_name)
          sys_info_ptr = FFI::MemoryPointer.new(SystemInfo.size)
          HardwareFFI::GetNativeSystemInfo(sys_info_ptr)
          sys_info = SystemInfo.new(sys_info_ptr)

          hard = determine_hardware(sys_info)
          arch = determine_architecture(hard)
          build_facts_list(hardware: hard, architecture: arch)
          @fact_list[fact_name]
        end

        def determine_hardware(sys_info)
          union = sys_info[:dummyunionname]
          struct = union[:dummystructname]
          case struct[:wProcessorArchitecture]
          when HardwareFFI::PROCESSOR_ARCHITECTURE_AMD64
            'x86_64'
          when HardwareFFI::PROCESSOR_ARCHITECTURE_ARM
            'arm'
          when HardwareFFI::PROCESSOR_ARCHITECTURE_IA64
            'ia64'
          when HardwareFFI::PROCESSOR_ARCHITECTURE_INTEL
            family = sys_info[:wProcessorLevel] > 5 ? 6 : sys_info[:wProcessorLevel]
            "i#{family}86"
          else
            'unknown'
          end
        end

        def determine_architecture(hardware)
          case hardware
          when /i[3456]86/
            'x86'
          when 'x86_64'
            'x64'
          else
            hardware
          end
        end

        def build_facts_list(facts)
          @fact_list[:hardware] = facts[:hardware]
          @fact_list[:architecture] = facts[:architecture]
        end
      end
    end
  end
end

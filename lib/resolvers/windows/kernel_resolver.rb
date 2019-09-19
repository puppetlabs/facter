# frozen_string_literal: true

module Facter
  module Resolvers
    class KernelResolver < BaseResolver
      @log = Facter::Log.new
      class << self
        @@semaphore = Mutex.new
        @@fact_list ||= {}

        def resolve(fact_name)
          @@semaphore.synchronize do
            result ||= @@fact_list[fact_name]
            subscribe_to_manager
            result || read_os_version_information(fact_name)
          end
        end

        def invalidate_cache
          @@fact_list = {}
        end

        private

        def read_os_version_information(fact_name)
          ver_ptr = FFI::MemoryPointer.new(OsVersionInfoEx.size)
          ver = OsVersionInfoEx.new(ver_ptr)
          ver[:dwOSVersionInfoSize] = OsVersionInfoEx.size

          if KernelFFI::RtlGetVersion(ver_ptr) != KernelFFI::STATUS_SUCCESS
            @log.debug 'Calling Windows RtlGetVersion failed'
            return
          end

          result = { major: ver[:dwMajorVersion], minor: ver[:dwMinorVersion], build: ver[:dwBuildNumber] }
          build_facts_list(result)

          @@fact_list[fact_name]
        end

        def build_facts_list(result)
          @@fact_list[:kernelversion] = "#{result[:major]}.#{result[:minor]}.#{result[:build]}"
          @@fact_list[:kernelmajorversion] = "#{result[:major]}.#{result[:minor]}"
          @@fact_list[:kernel] = 'windows'
        end
      end
    end
  end
end

# frozen_string_literal: true

module Facter
  module Resolvers
    class System32 < BaseResolver
      @log = Facter::Log.new(self)
      @semaphore = Mutex.new
      @fact_list ||= {}
      class << self
        def resolve(fact_name)
          @semaphore.synchronize do
            result ||= @fact_list[fact_name]
            subscribe_to_manager
            result || retrieve_windows_binaries_path
          end
        end

        private

        def retrieve_windows_binaries_path
          windows_path = ENV['SystemRoot']

          if !windows_path || windows_path.empty?
            @log.debug 'Unable to find correct value for SystemRoot enviroment variable'
            return nil
          end

          bool_ptr = FFI::MemoryPointer.new(:win32_bool, 1)
          if System32FFI::IsWow64Process(System32FFI::GetCurrentProcess(), bool_ptr) == FFI::WIN32_FALSE
            @log.debug 'IsWow64Process failed'
            return
          end

          @fact_list[:system32] = construct_path(bool_ptr, windows_path)
        end

        def construct_path(bool_ptr, windows)
          if bool_ptr.read_win32_bool
            "#{windows}\\sysnative"
          else
            "#{windows}\\system32"
          end
        end
      end
    end
  end
end

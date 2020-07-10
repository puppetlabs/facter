# frozen_string_literal: true

module Facter
  module Resolvers
    class System32 < BaseResolver
      @log = Facter::Log.new(self)
      @semaphore = Mutex.new
      @fact_list ||= {}
      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { retrieve_windows_binaries_path }
        end

        def retrieve_windows_binaries_path
          require 'facter/resolvers/windows/ffi/system32_ffi'

          windows_path = ENV['SystemRoot']

          if !windows_path || windows_path.empty?
            @log.debug 'Unable to find correct value for SystemRoot enviroment variable'
            return nil
          end

          bool_ptr = FFI::MemoryPointer.new(:win32_bool, 1)
          if System32FFI::IsWow64Process(System32FFI::GetCurrentProcess(), bool_ptr) == FFI::WIN32FALSE
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

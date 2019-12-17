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
          path_ptr = FFI::MemoryPointer.new(:wchar, MAX_PATH + 1)
          if System32FFI::SHGetFolderPathW(0, System32FFI::CSIDL_WINDOWS, 0, 0, path_ptr) != System32FFI::H_OK
            @log.debug 'SHGetFolderPath failed'
            return
          end

          windows = path_ptr.read_wide_string_with_length(MAX_PATH).strip

          bool_ptr = FFI::MemoryPointer.new(:win32_bool, 1)
          if System32FFI::IsWow64Process(System32FFI::GetCurrentProcess(), bool_ptr) == FFI::WIN32_FALSE
            @log.debug 'IsWow64Process failed'
            return
          end

          @fact_list[:system32] = construct_path(bool_ptr, windows)
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

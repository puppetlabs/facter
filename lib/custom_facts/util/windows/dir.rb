# frozen_string_literal: true

require 'ffi'

module LegacyFacter
  module Util
    module Windows
      module Dir
        extend ::FFI::Library

        COMMON_APPDATA = 0x0023
        S_OK           = 0x0
        MAX_PATH       = 260

        module_function

        def common_appdata
          common_appdata = ''

          # this pointer actually points to a :lpwstr (pointer) since we're letting Windows allocate for us
          ::FFI::MemoryPointer.new(:pointer, ((MAX_PATH + 1) * 2)) do |buffer_ptr|
            # hwndOwner, nFolder, hToken, dwFlags, pszPath
            if SHGetFolderPathW(0, COMMON_APPDATA, 0, 0, buffer_ptr) != S_OK
              raise LegacyFacter::Util::Windows::Error, 'Could not find COMMON_APPDATA path'
            end

            common_appdata = LegacyFacter::Util::Windows::FFI.read_arbitrary_wide_string_up_to(buffer_ptr, MAX_PATH + 1)
          end

          common_appdata
        end

        ffi_convention :stdcall

        # https://msdn.microsoft.com/en-us/library/windows/desktop/bb762181(v=vs.85).aspx
        # HRESULT SHGetFolderPath(
        #   _In_  HWND   hwndOwner,
        #   _In_  int    nFolder,
        #   _In_  HANDLE hToken,
        #   _In_  DWORD  dwFlags,
        #   _Out_ LPTSTR pszPath
        # );
        ffi_lib :shell32
        attach_function :SHGetFolderPathW,
                        %i[handle int32 handle dword lpwstr], :hresult
      end
    end
  end
end

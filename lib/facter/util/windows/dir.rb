require 'facter/util/windows'
require 'ffi'

module Facter::Util::Windows::Dir
  extend FFI::Library

  COMMON_APPDATA = 0x0023
  S_OK           = 0x0
  MAX_PATH       = 260;

  def get_common_appdata
    common_appdata = ''

    # this pointer actually points to a :lpwstr (pointer) since we're letting Windows allocate for us
    FFI::MemoryPointer.new(:pointer, ((MAX_PATH + 1) * 2)) do |buffer_ptr|
      # hwndOwner, nFolder, hToken, dwFlags, pszPath
      if SHGetFolderPathW(0, COMMON_APPDATA, 0, 0, buffer_ptr) != S_OK
        raise Facter::Util::Windows::Error.new("Could not find COMMON_APPDATA path")
      end

      common_appdata = buffer_ptr.read_arbitrary_wide_string_up_to(MAX_PATH + 1)
    end

    common_appdata
  end
  module_function :get_common_appdata

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
  attach_function_private :SHGetFolderPathW,
    [:handle, :int32, :handle, :dword, :lpwstr], :hresult
end

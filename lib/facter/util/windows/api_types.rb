require 'ffi'

module Facter::Util::Windows::ApiTypes
  module ::FFI
    WIN32_FALSE = 0

    # standard Win32 error codes
    ERROR_SUCCESS = 0
  end

  module ::FFI::Library
    # Wrapper method for attach_function + private
    def attach_function_private(*args)
      attach_function(*args)
      private args[0]
    end
  end

  class ::FFI::Pointer
    NULL_HANDLE = 0

    def read_win32_bool
      # BOOL is always a 32-bit integer in Win32
      # some Win32 APIs return 1 for true, while others are non-0
      read_int32 != FFI::WIN32_FALSE
    end
    #
    alias_method :read_dword, :read_uint32

    def read_handle
      type_size == 4 ? read_uint32 : read_uint64
    end

    def read_wide_string(char_length, dst_encoding = Encoding::UTF_8)
      # char_length is number of wide chars (typically excluding NULLs), *not* bytes
      str = get_bytes(0, char_length * 2).force_encoding('UTF-16LE')
      str.encode(dst_encoding)
    end

    def read_win32_local_pointer(&block)
      ptr = nil
      begin
        ptr = read_pointer
        yield ptr
      ensure
        if ptr && ! ptr.null?
          if FFI::WIN32::LocalFree(ptr.address) != FFI::Pointer::NULL_HANDLE
            Puppet.debug "LocalFree memory leak"
          end
        end
      end

      # ptr has already had LocalFree called, so nothing to return
      nil
    end
  end
  # FFI Types
  # https://github.com/ffi/ffi/wiki/Types

  # Windows - Common Data Types
  # https://msdn.microsoft.com/en-us/library/cc230309.aspx

  # Windows Data Types
  # https://msdn.microsoft.com/en-us/library/windows/desktop/aa383751(v=vs.85).aspx

  FFI.typedef :uint32, :dword
  FFI.typedef :uintptr_t, :handle

  # pointer in FFI is platform specific
  # NOTE: for API calls with reserved lpvoid parameters, pass a FFI::Pointer::NULL
  FFI.typedef :pointer, :lpcvoid
  FFI.typedef :pointer, :lpvoid
  FFI.typedef :pointer, :lpdword
  FFI.typedef :pointer, :pdword
  FFI.typedef :pointer, :phandle
  FFI.typedef :pointer, :pbool

  # FFI bool can be only 1 byte at times,
  # Win32 BOOL is a signed int, and is always 4 bytes, even on x64
  # https://blogs.msdn.com/b/oldnewthing/archive/2011/03/28/10146459.aspx
  FFI.typedef :int32, :win32_bool

  # 8 bits per byte
  FFI.typedef :uchar, :byte
  FFI.typedef :uint16, :wchar

  module ::FFI::WIN32
    extend ::FFI::Library

    ffi_convention :stdcall

    # https://msdn.microsoft.com/en-us/library/windows/desktop/aa366730(v=vs.85).aspx
    # HLOCAL WINAPI LocalFree(
    #   _In_  HLOCAL hMem
    # );
    ffi_lib :kernel32
    attach_function :LocalFree, [:handle], :handle

    # https://msdn.microsoft.com/en-us/library/windows/desktop/ms724211(v=vs.85).aspx
    # BOOL WINAPI CloseHandle(
    #   _In_  HANDLE hObject
    # );
    ffi_lib :kernel32
    attach_function_private :CloseHandle, [:handle], :win32_bool
  end
end

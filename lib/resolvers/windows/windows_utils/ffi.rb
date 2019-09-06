# frozen_string_literal: true

require 'ffi'

FFI.typedef :uint16, :word
FFI.typedef :uint32, :dword
FFI.typedef :uintptr_t, :handle
FFI.typedef :buffer_inout, :lpwstr
FFI.typedef :pointer, :lpcvoid
FFI.typedef :pointer, :lpvoid
FFI.typedef :pointer, :lpdword
FFI.typedef :pointer, :pdword
FFI.typedef :pointer, :phandle
FFI.typedef :pointer, :pbool
FFI.typedef :pointer, :ulong_ptr
FFI.typedef :uint32, :win32_ulong
FFI.typedef :int32, :win32_long
FFI.typedef :int32, :win32_bool
FFI.typedef :uint16, :wchar
FFI.typedef :uintptr_t, :hwnd

ERROR_MORE_DATA = 234
MAX_PATH = 32_767

module FFI
  WIN32_FALSE = 0

  class Pointer
    alias write_dword write_uint32
    alias read_dword read_uint32

    def read_wide_string(char_length)
      # char_length is number of wide chars (typically excluding NULLs), *not* bytes
      str = get_bytes(0, char_length * 2).force_encoding('UTF-16LE')
      str.encode('UTF-8', str.encoding, {})
    end

    def read_win32_bool
      # BOOL is always a 32-bit integer in Win32
      # some Win32 APIs return 1 for true, while others are non-0
      read_int32 != FFI::WIN32_FALSE
    end
  end
end

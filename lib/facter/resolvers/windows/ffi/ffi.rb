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
  WIN32FALSE = 0
  END_OF_WCHAR_STRING = "\0\0".encode('UTF-16LE')

  class Pointer
    def read_wide_string_with_length(char_length)
      # char_length is number of wide chars (typically excluding NULLs), *not* bytes
      str = get_bytes(0, char_length * 2).force_encoding('UTF-16LE')
      str.encode('UTF-8', str.encoding, {})
    end

    def read_wide_string_without_length
      wide_character = get_bytes(0, 2)
      i = 2
      str = []

      while wide_character.encode('UTF-16LE') != END_OF_WCHAR_STRING
        str << wide_character
        wide_character = get_bytes(i, 2)
        i += 2
      end
      str.join.force_encoding('UTF-16LE').encode('UTF-8')
    end

    def read_win32_bool
      # BOOL is always a 32-bit integer in Win32
      # some Win32 APIs return 1 for true, while others are non-0
      read_int32 != WIN32FALSE
    end
  end

  class Struct
    def self.read_list(first_address)
      instance = new(first_address)
      while instance.to_ptr != Pointer::NULL
        yield(instance)
        instance = new(instance[:Next])
      end
    end
  end
end

# frozen_string_literal: true

require_relative '../../../../facter/resolvers/windows/ffi/ffi'

module System32FFI
  extend FFI::Library

  ffi_convention :stdcall
  ffi_lib :kernel32
  attach_function :IsWow64Process, %i[handle pointer], :win32_bool

  ffi_convention :stdcall
  ffi_lib :kernel32
  attach_function :GetCurrentProcess, [], :handle

  CSIDL_WINDOWS = 0x0024
  H_OK = 0
end

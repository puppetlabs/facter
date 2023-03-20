# frozen_string_literal: true

require_relative 'ffi'
require_relative 'os_version_info_ex'

module KernelFFI
  extend FFI::Library

  ffi_convention :stdcall
  ffi_lib :ntdll
  attach_function :RtlGetVersion, [:pointer], :int32

  STATUS_SUCCESS = 0
end

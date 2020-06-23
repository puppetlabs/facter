# frozen_string_literal: true

require 'facter/resolvers/windows/ffi/ffi'
require 'facter/resolvers/windows/ffi/os_version_info_ex'

module KernelFFI
  extend FFI::Library

  ffi_convention :stdcall
  ffi_lib [FFI::CURRENT_PROCESS, :ntdll]
  attach_function :RtlGetVersion, [:pointer], :int32

  STATUS_SUCCESS = 0
end

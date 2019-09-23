# frozen_string_literal: true

module KernelFFI
  extend FFI::Library

  ffi_convention :stdcall
  ffi_lib [FFI::CURRENT_PROCESS, :ntdll]
  attach_function :RtlGetVersion, [:pointer], :int32

  STATUS_SUCCESS = 0
end

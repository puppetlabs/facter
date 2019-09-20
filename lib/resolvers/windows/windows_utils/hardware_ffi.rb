# frozen_string_literal: true

module HardwareFFI
  extend FFI::Library

  ffi_convention :stdcall
  ffi_lib :kernel32
  attach_function :GetNativeSystemInfo, [:pointer], :void

  PROCESSOR_ARCHITECTURE_INTEL = 0
  PROCESSOR_ARCHITECTURE_ARM = 5
  PROCESSOR_ARCHITECTURE_IA64 = 6
  PROCESSOR_ARCHITECTURE_AMD64 = 9
end

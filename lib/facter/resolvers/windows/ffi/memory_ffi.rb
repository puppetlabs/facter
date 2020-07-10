# frozen_string_literal: true

require 'facter/resolvers/windows/ffi/ffi'
require 'facter/resolvers/windows/ffi/performance_information'

module MemoryFFI
  extend FFI::Library

  ffi_convention :stdcall
  ffi_lib :psapi
  attach_function :GetPerformanceInfo, %i[pointer dword], :win32_bool
end

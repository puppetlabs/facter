# frozen_string_literal: true

require 'ffi'

module Uptime
  extend FFI::Library

  ffi_convention :stdcall
  ffi_lib :kernel32
  attach_function :GetTickCount64, [], :ulong_long
end

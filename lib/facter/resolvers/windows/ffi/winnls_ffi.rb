# frozen_string_literal: true

require_relative '../../../../facter/resolvers/windows/ffi/ffi'

module WinnlsFFI
  extend FFI::Library

  ffi_convention :stdcall
  ffi_lib :kernel32
  attach_function :GetACP, [], :uint
end

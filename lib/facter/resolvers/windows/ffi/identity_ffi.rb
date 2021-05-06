# frozen_string_literal: true

require_relative '../../../../facter/resolvers/windows/ffi/ffi'

module IdentityFFI
  extend FFI::Library

  ffi_convention :stdcall
  ffi_lib :secur32
  attach_function :GetUserNameExW, %i[uint32 lpwstr pointer], :win32_bool

  ffi_convention :stdcall
  ffi_lib :shell32
  attach_function :IsUserAnAdmin, [], :win32_bool
end

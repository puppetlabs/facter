# frozen_string_literal: true

module FFI
  def self.typedef(arg1, arg2); end
  module Library
    def ffi_convention(arg); end

    def ffi_lib(arg); end

    def attach_function(function, args, return_type); end
  end

  class Pointer
    def write_uint32(); end
    def read_uint32(); end
  end
end

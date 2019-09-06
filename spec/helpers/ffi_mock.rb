# frozen_string_literal: true

module FFI
  ERROR_MORE_DATA = 234
  @error_number = nil
  def self.typedef(arg1, arg2); end

  def self.errno
    @error_number
  end

  def self.define_errno(arg)
    @error_number = arg
  end

  module Library
    def ffi_convention(arg); end

    def ffi_lib(arg); end

    def attach_function(function, args, return_type); end
  end

  class Pointer
    NULL = nil
    def write_uint32(); end

    def read_uint32(); end
  end

  class MemoryPointer
    def initialize; end
  end
end

# frozen_string_literal: true

module FFI
  module Library
    def ffi_convention(arg); end

    def ffi_lib(arg); end

    def attach_function(function, args, return_type); end
  end
end

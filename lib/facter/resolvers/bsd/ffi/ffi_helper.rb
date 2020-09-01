# frozen_string_literal: true

require 'ffi'

module Facter
  module Bsd
    module FfiHelper
      module Libc
        extend FFI::Library

        ffi_lib 'c'
        attach_function :sysctl, %i[pointer uint pointer pointer pointer size_t], :int
      end

      def self.sysctl(type, oids)
        name = FFI::MemoryPointer.new(:uint, oids.size)
        name.write_array_of_uint(oids)
        namelen = oids.size

        oldp = FFI::Pointer::NULL
        oldlenp = FFI::MemoryPointer.new(:size_t)

        newp = FFI::Pointer::NULL
        newlen = 0

        if type == :string
          res = Libc.sysctl(name, namelen, oldp, oldlenp, newp, newlen)
          return nil if res.negative?
        else
          oldlenp.write(:size_t, FFI.type_size(type))
        end

        oldp = FFI::MemoryPointer.new(:uint8_t, oldlenp.read(:size_t))
        res = Libc.sysctl(name, namelen, oldp, oldlenp, newp, newlen)
        return nil if res.negative?

        case type
        when :string
          oldp.read_string
        else
          oldp.read(type)
        end
      end
    end
  end
end

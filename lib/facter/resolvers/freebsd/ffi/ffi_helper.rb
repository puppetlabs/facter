# frozen_string_literal: true

require 'ffi'

module Facter
  module Freebsd
    module FfiHelper
      module Libc
        extend FFI::Library

        ffi_lib 'c'
        attach_function :sysctlbyname, %i[string pointer pointer pointer size_t], :int
      end

      def self.sysctl_by_name(type, name)
        oldp = FFI::Pointer::NULL
        oldlenp = FFI::MemoryPointer.new(:size_t)

        newp = FFI::Pointer::NULL
        newlenp = 0

        if type == :string
          res = Libc.sysctlbyname(name, oldp, oldlenp, newp, newlenp)
          return nil if res.negative?
        else
          oldlenp.write(:size_t, FFI.type_size(type))
        end

        oldp = FFI::MemoryPointer.new(:uint8_t, oldlenp.read(:size_t))
        res = Libc.sysctlbyname(name, oldp, oldlenp, newp, newlenp)
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

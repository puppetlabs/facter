# frozen_string_literal: true

require 'ffi'

module Facter
  module Freebsd
    module FfiHelper
      module Libc
        extend FFI::Library

        KENV_GET = 0

        KENV_MVALLEN = 128

        ffi_lib 'c'
        attach_function :kenv, %i[int string pointer int], :int
        attach_function :sysctlbyname, %i[string pointer pointer pointer size_t], :int
      end

      def self.kenv(action, name, value = nil)
        case action
        when :get
          len = Libc::KENV_MVALLEN + 1
          value = FFI::MemoryPointer.new(:char, len)
          res = Libc.kenv(Libc::KENV_GET, name, value, len)
          return nil if res.negative?

          value.read_string(res).chomp("\0")
        else
          raise "Action #{action} not supported"
        end
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

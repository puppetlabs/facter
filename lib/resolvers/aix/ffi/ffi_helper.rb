# frozen_string_literal: true

require 'ffi'

module Facter
  module Aix
    module FfiHelper
      KINFO_GET_AVENRUN = 1
      KINFO_READ        = 8 << 8

      module Libc
        extend FFI::Library

        RTLD_LAZY   = 0x00000004
        RTLD_GLOBAL = 0x00010000
        RTLD_MEMBER = 0x00040000

        @ffi_lib_flags = RTLD_LAZY | RTLD_GLOBAL | RTLD_MEMBER
        ffi_lib 'libc.a(shr.o)'

        attach_function :getkerninfo, %i[int pointer pointer int], :int
      end

      def self.read_load_averages
        averages = FFI::MemoryPointer.new(:long_long, 3)
        averages_size = FFI::MemoryPointer.new(:int, 1)
        averages_size.write_int(averages.size)

        return if Libc.getkerninfo(KINFO_READ | KINFO_GET_AVENRUN, averages, averages_size, 0).negative?

        averages.read_array_of_long_long(3).map { |x| (x / 65_536.0).round(5) }
      end
    end
  end
end

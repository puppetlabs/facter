# frozen_string_literal: true

require 'ffi'

module Facter
  module Bsd
    module FfiHelper
      module Libc
        extend FFI::Library

        ffi_lib 'c'
        attach_function :getloadavg, %i[pointer int], :int
      end

      def self.read_load_averages
        raw_loadavg = FFI::MemoryPointer.new(:double, 3)

        res = Libc.getloadavg(raw_loadavg, 3)
        return unless res == 3

        raw_loadavg.read_array_of_double(res)
      end
    end
  end
end

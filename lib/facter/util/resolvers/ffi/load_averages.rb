# frozen_string_literal: true

require 'ffi'

module Facter
  module Util
    module Resolvers
      module Ffi
        module LoadAverages
          extend ::FFI::Library
          ffi_lib ::FFI::Library::LIBC

          attach_function :getloadavg, %i[pointer int], :int

          def self.read_load_averages
            raw_loadavg = ::FFI::MemoryPointer.new(:double, 3)

            res = LoadAverages.getloadavg(raw_loadavg, 3)
            return unless res == 3

            raw_loadavg.read_array_of_double(res)
          end
        end
      end
    end
  end
end

require 'ffi'
require 'json'

module CFacter
  private
  extend FFI::Library
  ffi_lib "libcfacter.so"

  # to_json is used for to_hash but no need to make it public
  attach_function :to_json,         [:pointer, :size_t],           :int

  class Constants
    JSON_STRING_MAX_LEN = 1024000
  end

  public
  attach_function :clear,           [],                            :void
  attach_function :loadfacts,       [],                            :void
  attach_function :value,           [:pointer, :pointer, :size_t], :int
  attach_function :search_external, [:pointer],                    :void

  def self.to_hash
    ptr = FFI::MemoryPointer.new(:char, Constants::JSON_STRING_MAX_LEN)
    success = to_json(ptr, Constants::JSON_STRING_MAX_LEN)
    if success != 0
      return {}
    end
    JSON.parse(ptr.read_string())
  end
end

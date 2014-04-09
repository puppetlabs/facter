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

  def self.to_hash
    ptr = FFI::MemoryPointer.new(:char, Constants::JSON_STRING_MAX_LEN)
    success = to_json(ptr, Constants::JSON_STRING_MAX_LEN)
    if success != 0
      return {}
    end
    JSON.parse(ptr.read_string())
  end

  def self.search(*dirs)
    # no ruby load paths for cfacter
  end

  def self.value(name)
    ptr = FFI::MemoryPointer.new(:char, Constants::JSON_STRING_MAX_LEN)
    success = c_value(name.to_s, ptr, Constants::JSON_STRING_MAX_LEN)
    if success != 0
      return ""
    end
    ptr.read_string()
  end

  CFact = Struct.new(:value)

  def self.[](name)
    CFact.new(value(name))
  end

  def search_external(dirs)
    dirs.each { |dir| c_search_external(dir) }
  end

  private
  attach_function :c_value,           :value,           [:string, :pointer, :size_t], :int
  attach_function :c_search_external, :search_external, [:pointer],                   :void

end

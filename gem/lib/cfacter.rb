require 'ffi'

module CFacter

  # This module defines cfacter's C interface in Ruby.
  module FacterLib
    extend FFI::Library

    begin
      ffi_lib ['libfacter', 'facter']
    rescue LoadError
      raise LoadError.new('libfacter was not found. Please make sure cfacter is installed.')
    end

    callback :string_callback,        [:string, :string],   :void
    callback :integer_callback,       [:string, :int64],    :void
    callback :boolean_callback,       [:string, :uint8],    :void
    callback :double_callback,        [:string, :double],   :void
    callback :array_start_callback,   [:string],            :void
    callback :array_end_callback,     [],                   :void
    callback :map_start_callback,     [:string],            :void
    callback :map_end_callback,       [],                   :void

    class EnumerationCallbacks < FFI::Struct
      layout :string,       :string_callback,
             :integer,      :integer_callback,
             :boolean,      :boolean_callback,
             :double,       :double_callback,
             :array_start,  :array_start_callback,
             :array_end,    :array_end_callback,
             :map_start,    :map_start_callback,
             :map_end,      :map_end_callback
    end

    attach_function :get_facter_version,    [],                     :string
    attach_function :load_facts,            [:string],              :void
    attach_function :clear_facts,           [],                     :void
    attach_function :search_external,       [:string],              :void
    attach_function :enumerate_facts,       [:pointer],             :void
    attach_function :get_fact_value,        [:string, :pointer],    :bool
  end

  FACTER_VERSION = '0.1.0'

  raise LoadError.new("Expected cfacter #{FACTER_VERSION} but found #{FacterLib.get_facter_version}.") if FacterLib.get_facter_version != FACTER_VERSION

  def self.version
    FacterLib.get_facter_version
  end

  def self.loadfacts
    FacterLib.load_facts nil
  end

  def self.clear
    FacterLib.clear_facts
  end

  # This method creates the callbacks used when enumerating facts from cfacter.
  # Each callback simply appends the corresponding Ruby type to the hash/array
  # being built up during the enumeration.  This allows us to effectively copy
  # the structure of the facts from cfacter into native Ruby types.
  def self.create_enumeration_callbacks(initial)
    callbacks = FacterLib::EnumerationCallbacks.new
    current = initial
    stack = []

    add = Proc.new do |name, value|
      if current.is_a? Array
        current << value
      else
        current[name] = value
      end
    end

    callbacks[:string] = Proc.new do |name, value|
      add.call name, value
    end

    callbacks[:integer] = Proc.new do |name, value|
      add.call name, value
    end

    callbacks[:boolean] = Proc.new do |name, value|
      add.call name, (value != 0)
    end

    callbacks[:double] = Proc.new do |name, value|
      add.call name, value
    end

    callbacks[:array_start] = Proc.new do |name|
      value = []
      add.call name, value
      stack.push current
      current = value
    end

    callbacks[:array_end] = Proc.new { current = stack.pop }

    callbacks[:map_start] = Proc.new do |name|
      value = {}
      add.call name, value
      stack.push current
      current = value
    end

    # Reuse the callback for array end since it has the same signature and
    # performs the same operation.
    callbacks[:map_end] = callbacks[:array_end]

    callbacks
  end

  def self.to_hash
    result = {}
    FacterLib.enumerate_facts(self.create_enumeration_callbacks(result))
    result
  end

  def self.value(name)
    # To share the enumeration callbacks with to_hash, pass in an array and return the
    # first element, which will be the value of the requested fact.
    result = []
    return nil unless FacterLib.get_fact_value(name, self.create_enumeration_callbacks(result))
    result[0]
  end
end

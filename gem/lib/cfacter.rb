require 'ffi'

module CFacter

  # This module defines cfacter's C interface in Ruby.
  #
  # @api private
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
    callback :path_callback,          [:string],            :void

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

    attach_function :get_facter_version,              [],                     :string
    attach_function :load_facts,                      [:string],              :void
    attach_function :clear_facts,                     [],                     :void
    attach_function :add_search_paths,                [:string, :string],     :void
    attach_function :enumerate_search_paths,          [:path_callback],       :void
    attach_function :clear_search_paths,              [],                     :void
    attach_function :add_external_search_paths,       [:string, :string],     :void
    attach_function :enumerate_external_search_paths, [:path_callback],       :void
    attach_function :clear_external_search_paths,     [],                     :void
    attach_function :enumerate_facts,                 [:pointer],             :void
    attach_function :get_fact_value,                  [:string, :pointer],    :bool
  end

  # Utility class for returning a typed fact
  class Fact
    attr_reader :name, :value

    def initialize(name, value)
      @name = name
      @value = value
    end
  end

  # The facter gem version.
  FACTER_VERSION = '0.2.0'

  # Ensure the facter library that was loaded matches the gem version.
  raise LoadError.new("Expected cfacter #{FACTER_VERSION} but found #{FacterLib.get_facter_version}.") if FacterLib.get_facter_version != FACTER_VERSION

  # Gets the version of the facter library that was loaded.
  #
  # @return [String] The facter library version string.
  # @api public
  def self.version
    FacterLib.get_facter_version
  end

  # Loads all facts.
  # This is a no-op if facts have already been loaded.
  # @return [void]
  # @api public
  def self.loadfacts
    FacterLib.load_facts nil
  end

  # Clears all cached values and removes all facts from memory.
  #
  # @return [void]
  # @api public
  def self.clear
    FacterLib.clear_facts
  end

  # Clears all cached values and removes all facts from memory.
  # Also removes all search directories.
  #
  # @return [void]
  # @api public
  def self.reset
    FacterLib.clear_facts
    reset_search_path!
    reset_external_search_path!
  end

  # Register directories to be searched for facts.
  # The registered directories must be absolute paths or they will be ignored.
  # @param dirs [String] directories to search
  # @return [void]
  # @api public
  def self.search(*dirs)
    FacterLib.add_search_paths(dirs.join(File::PATH_SEPARATOR), File::PATH_SEPARATOR)
  end

  # Returns the registered search directories.
  #
  # @return [Array<String>] An array of the directories that will be searched.
  # @api public
  def self.search_path
    paths = []
    callback = Proc.new do |path|
      paths << path
    end
    FacterLib.enumerate_search_paths(callback)
    paths
  end

  # Reset the fact search directories.
  #
  # @return [void]
  # @api private
  def self.reset_search_path!
    FacterLib.clear_search_paths
  end

  # Registers directories to be searched for external facts.
  #
  # @param dirs [Array<String>] directories to search
  # @return [void]
  # @api public
  def self.search_external(dirs)
    FacterLib.add_external_search_paths(dirs.join(File::PATH_SEPARATOR), File::PATH_SEPARATOR)
  end

  # Returns the registered external search directories.
  #
  # @return [Array<String>] An array of the directories that will be searched.
  # @api public
  def self.search_external_path
    paths = []
    callback = Proc.new do |path|
      paths << path
    end
    FacterLib.enumerate_external_search_paths(callback)
    paths
  end

  # Reset the external search directories.
  #
  # @return [void]
  # @api private
  def self.reset_external_search_path!
    FacterLib.clear_external_search_paths
  end

  # Creates callbacks used when enumerating facts from cfacter.
  # Each callback simply appends the corresponding Ruby type to the hash/array
  # being built up during the enumeration.  This allows us to effectively copy
  # the structure of the facts from cfacter into native Ruby types.
  # @param initial The initial object to populate with facts.
  # @return [EnumerationCallbacks] The enumeration callbacks.
  # @api private
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

  # Gets a hash mapping fact names to their values
  #
  # @return [Hash{String => Object}] the hash of fact names and values
  # @api public
  def self.to_hash
    FacterLib.load_facts nil
    result = {}
    FacterLib.enumerate_facts(self.create_enumeration_callbacks(result))
    result
  end

  # Gets the value for a fact. Returns `nil` if no such fact exists.
  #
  # @param name [String] The fact name.
  # @return [Object, nil] The value of the fact, or nil if no fact is found.
  # @api public
  def self.value(name)
    FacterLib.load_facts nil
    # To share the enumeration callbacks with to_hash, pass in an array and return the
    # first element, which will be the value of the requested fact.
    result = []
    return unless FacterLib.get_fact_value(name.to_s, self.create_enumeration_callbacks(result))
    result[0]
  end

  # Gets a typed fact by name.
  #
  # @param name [String] The fact name.
  # @return [Fact, nil] The typed fact, or nil if no fact is found.
  # @api public
  def self.[](name)
    value = self.value(name)
    return unless value
    Fact.new(name.to_s, value)
  end
end

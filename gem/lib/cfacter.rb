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

    attach_function :facter_version,        [],         :string
    attach_function :initialize_facter,     [:uint],    :void
    attach_function :shutdown_facter,       [],         :void
  end

  # Represents the Facter logging levels.
  #
  # @api public
  module LogLevel
    NONE    = 0
    TRACE   = 1
    DEBUG   = 2
    INFO    = 3
    WARNING = 4
    ERROR   = 5
    FATAL   = 6
  end

  # The version of the gem.
  GEM_VERSION = '0.2.0'

  # Ensure the facter library that was loaded matches the gem version.
  raise LoadError.new("Expected cfacter #{GEM_VERSION} but found #{FacterLib.facter_version}.") if FacterLib.facter_version != GEM_VERSION

  # Gets the version of cfacter.
  #
  # @return [String] The version of cfacter.
  # @api public
  def self.version
    FacterLib.facter_version
  end

  # Initializes the cfacter gem.
  #
  # @param level [Fixnum] The logging level. See LogLevel for possible values.
  # @api public
  def self.initialize(level = LogLevel::WARNING)
    FacterLib.initialize_facter level
  end

  # Shuts down the cfacter gem.
  #
  # @api public
  def self.shutdown
    FacterLib.shutdown_facter
  end
end

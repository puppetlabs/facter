require 'facter'

module Facter::Core::Logging

  extend self

  # @api private
  GREEN = "[0;32m"
  # @api private
  RESET = "[0m"

  # @api private
  @@debug = false
  # @api private
  @@timing = false
  # @api private
  @@warn_messages = {}
  # @api private
  @@debug_messages = {}

  # Prints a debug message if debugging is turned on
  #
  # @param msg [String] the debug message
  # @return [void]
  def debug(msg)
    if self.debugging?
      if msg.nil? or msg.empty?
        invoker = caller[0].slice(/.*:\d+/)
        self.warn "#{self.class}#debug invoked with invalid message #{msg.inspect}:#{msg.class} at #{invoker}"
      else
        puts GREEN + msg + RESET
      end
    end
  end

  # Prints a debug message only once.
  #
  # @note Uniqueness is based on the string, not the specific location
  #   of the method call.
  #
  # @param msg [String] the debug message
  # @return [void]
  def debugonce(msg)
    if msg and not msg.empty? and @@debug_messages[msg].nil?
      @@debug_messages[msg] = true
      debug(msg)
    end
  end

  # Prints a warning message. The message is only printed if debugging
  # is enabled.
  #
  # @param msg [String] the warning message to be printed
  #
  # @return [void]
  def warn(msg)
    if msg.nil? or msg.empty?
      invoker = caller[0].slice(/.*:\d+/)
      Kernel.warn "#{self.class}#debug invoked with invalid message #{msg.inspect}:#{msg.class} at #{invoker}"
    else
      Kernel.warn msg
    end
  end

  # Prints a warning message only once per process. Each unique string
  # is printed once.
  #
  # @note Unlike {warn} the message will be printed even if debugging is
  #   not turned on. This behavior is likely to change and should not be
  #   relied on.
  #
  # @param msg [String] the warning message to be printed
  #
  # @return [void]
  def warnonce(msg)
    if @@warn_messages[msg].nil?
      self.warn(msg)
      @@warn_messages[msg] = true
    end
  end

  # Print timing information
  #
  # @param string [String] the time to print
  # @return [void]
  #
  # @api private
  def show_time(string)
    $stderr.puts "#{GREEN}#{string}#{RESET}" if string and self.timing?
  end

  # Enable or disable logging of debug messages
  #
  # @param bool [true, false]
  # @return [void]
  #
  # @api private
  def debugging(bool)
    @@debug = bool
  end

  # Is debugging enabled?
  #
  # @return [true, false]
  #
  # @api private
  def debugging?
    @@debug
  end

  # Enable or disable logging of timing information
  #
  # @param bool [true, false]
  # @return [void]
  #
  # @api private
  def timing(bool)
    @@timing = bool
  end

  # Returns whether timing output is turned on
  #
  # @api private
  def timing?
    @@timing
  end

  # Clears the seen state of warning messages. See {warnonce}.
  #
  # @return [void]
  #
  # @api private
  def clear_messages
    @@warn_messages.clear
  end
end

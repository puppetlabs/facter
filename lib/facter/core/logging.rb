require 'facter'

module Facter::Core::Logging

  extend self

  # @api private
  GREEN = "[0;32m"
  # @api private
  RESET = "[0m"

  # @api private
  @@debug = 0
  # @api private
  @@timing = 0
  # @api private
  @@warn_messages = {}
  # @api private
  @@debug_messages = {}

  # Prints a debug message if debugging is turned on
  #
  # @param string [String] the debug message
  # @return [void]
  def debug(string)
    if string.nil?
      return
    end
    if self.debugging?
      puts GREEN + string + RESET
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
    if self.debugging? and msg and not msg.empty?
      msg = [msg] unless msg.respond_to? :each
      msg.each { |line| Kernel.warn line }
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
    if msg and not msg.empty? and @@warn_messages[msg].nil?
      @@warn_messages[msg] = true
      Kernel.warn(msg)
    end
  end

  # Print timing information
  #
  # @param string [String] the time to print
  # @return [void]
  #
  # @api private
  def show_time(string)
    puts "#{GREEN}#{string}#{RESET}" if string and self.timing?
  end

  # Sets debugging on or off.
  #
  # @return [void]
  #
  # @api private
  def debugging(bit)
    if bit
      case bit
      when TrueClass; @@debug = 1
      when FalseClass; @@debug = 0
      when Fixnum
        if bit > 0
          @@debug = 1
        else
          @@debug = 0
        end
      when String;
        if bit.downcase == 'off'
          @@debug = 0
        else
          @@debug = 1
        end
      else
        @@debug = 0
      end
    else
      @@debug = 0
    end
  end

  # Returns whether debugging output is turned on
  def debugging?
    @@debug != 0
  end

  # Sets whether timing messages are displayed.
  #
  # @return [void]
  #
  # @api private
  def timing(bit)
    if bit
      case bit
      when TrueClass; @@timing = 1
      when Fixnum
        if bit > 0
          @@timing = 1
        else
          @@timing = 0
        end
      end
    else
      @@timing = 0
    end
  end

  # Returns whether timing output is turned on
  #
  # @api private
  def timing?
    @@timing != 0
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

# frozen_string_literal: true

module LegacyFacter
  module Core
    module Logging
      extend self

      # @api private
      GREEN = "\e[0;32m"
      # @api private
      RESET = "\e[0m"

      RED = "\e[31m"

      # @api private
      @@debug = false
      # @api private
      @@timing = false
      # @api private
      @@trace = false

      # @api private
      @@warn_messages = {}
      # @api private
      @@debug_messages = {}

      # @api private
      @@message_callback = nil

      # Used to register a callback that is called when a message is logged.
      # If a block is given, Facter will not log messages.
      # If a block is not given, Facter will resume logging messages.
      # @param block [Proc] the callback to call when a message is logged.
      #   The first argument to the callback will be a symbol representing a level. The supported
      #   levels are: :trace, :debug, :info, :warn, :error, and :fatal.
      #   The second argument to the callback will be a string containing the message
      #   that was logged.
      # @api public
      def on_message(&block)
        @@message_callback = block
      end

      # Prints a debug message if debugging is turned on
      #
      # @param msg [String] the debug message
      # @return [void]
      def debug(msg)
        return unless debugging?

        if msg.nil? || msg.empty?
          invoker = caller(1..1).first.slice(/.*:\d+/)
          self.warn "#{self.class}#debug invoked with invalid message #{msg.inspect}:#{msg.class} at #{invoker}"
        elsif @@message_callback
          @@message_callback.call(:debug, msg)
        else
          puts GREEN + msg + RESET
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
        return unless msg && !msg.empty? && @@debug_messages[msg].nil?

        @@debug_messages[msg] = true
        debug(msg)
      end

      # Prints a warning message. The message is only printed if debugging
      # is enabled.
      #
      # @param msg [String] the warning message to be printed
      #
      # @return [void]
      def warn(msg)
        if msg.nil? || msg.empty?
          invoker = caller(1..1).first.slice(/.*:\d+/)
          msg = "#{self.class}#debug invoked with invalid message #{msg.inspect}:#{msg.class} at #{invoker}"
        end
        if @@message_callback
          @@message_callback.call(:warn, msg)
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
        return unless @@warn_messages[msg].nil?

        self.warn(msg)
        @@warn_messages[msg] = true
      end

      def log_exception(exception, message = :default)
        self.warn(format_exception(exception, message, @@trace))
      end

      def format_exception(exception, message, trace)
        arr = []

        if message == :default
          arr << exception.message
        elsif message
          arr << message
        end

        if trace
          arr << 'backtrace:'
          arr.concat(exception.backtrace)
        end

        "#{RED}#{arr.flatten.join("\n")}#{RESET}"
      end

      # Print an exception message, and optionally a backtrace if trace is set

      # Print timing information
      #
      # @param string [String] the time to print
      # @return [void]
      #
      # @api private
      def show_time(string)
        return unless string && timing?

        if @@message_callback
          @@message_callback.call(:info, string)
        else
          $stderr.puts "#{GREEN}#{string}#{RESET}"
        end
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

      def trace(bool)
        @@trace = bool
      end

      def trace?
        @@trace
      end

      # Clears the seen state of debug and warning messages. See {debugonce} and {warnonce}.
      #
      # @return [void]
      #
      # @api private
      def clear_messages
        @@debug_messages.clear
        @@warn_messages.clear
      end
    end
  end
end

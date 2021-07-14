# frozen_string_literal: true

require 'logger'

module Facter
  RED     = "\e[31m"
  GREEN   = "\e[32m"
  YELLOW  = "\e[33m"
  CYAN    = "\e[36m"
  RESET   = "\e[0m"

  DEFAULT_LOG_LEVEL = :warn

  class Log
    @@logger = nil
    @@message_callback = nil
    @@has_errors = false
    @@debug_messages = []
    @@warn_messages = []
    @@timing = false

    class << self
      def clear_messages
        @@debug_messages.clear
        @@warn_messages.clear
      end

      def on_message(&block)
        @@message_callback = block
      end

      def level=(log_level)
        @@logger.level = log_level
      end

      def level
        @@logger.level
      end

      def errors?
        @@has_errors
      end

      def output(output)
        return if @@logger

        @@logger = Logger.new(output)
        set_logger_format
        @@logger.level = DEFAULT_LOG_LEVEL
      end

      def set_logger_format
        @@logger.formatter = proc do |severity, datetime, _progname, msg|
          datetime = datetime.strftime(@datetime_format || '%Y-%m-%d %H:%M:%S.%6N ')
          "[#{datetime}] #{severity} #{msg} \n"
        end
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
          warn("#{GREEN}#{string}#{RESET}")
        end
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
    end

    def initialize(logged_class)
      @class_name = LoggerHelper.determine_callers_name(logged_class)
      return unless @@logger.nil?

      @@logger = Logger.new(STDOUT)
      @@logger.level = DEFAULT_LOG_LEVEL
    end

    def debug(msg)
      return unless debugging_active?

      if @@message_callback && Options[:allow_external_loggers]
        @@message_callback.call(:debug, msg)
      else
        msg = colorize(msg, CYAN) if Options[:color]
        @@logger.debug(@class_name + ' - ' + msg)
      end
    end

    def debugonce(msg)
      return unless debugging_active?

      message_string = msg.to_s
      return if @@debug_messages.include? message_string

      @@debug_messages << message_string
      debug(message_string)
    end

    def info(msg)
      if msg.nil? || msg.empty?
        empty_message_error(msg)
      elsif @@message_callback && Options[:allow_external_loggers]
        @@message_callback.call(:info, msg)
      else
        msg = colorize(msg, GREEN) if Options[:color]
        @@logger.info(@class_name + ' - ' + msg)
      end
    end

    def warn(msg)
      if @@message_callback && Options[:allow_external_loggers]
        @@message_callback.call(:warn, msg)
      else
        msg = colorize(msg, YELLOW) if Options[:color]
        @@logger.warn(@class_name + ' - ' + msg)
      end
    end

    def warnonce(message)
      message_string = message.to_s
      return if @@warn_messages.include? message_string

      @@warn_messages << message_string
      warn(message_string)
    end

    def error(msg, colorize = false)
      @@has_errors = true

      if @@message_callback && Options[:allow_external_loggers]
        @@message_callback.call(:error, msg)
      else
        msg = colorize(msg, RED) if colorize || Options[:color]
        @@logger.error(@class_name + ' - ' + msg)
      end
    end

    def log_exception(exception)
      msg = exception.message
      msg += "\n" + exception.backtrace.join("\n") if Options[:trace]

      error(msg, true)
    end

    private

    def colorize(msg, color)
      "#{color}#{msg}#{RESET}"
    end

    def debugging_active?
      return true unless Facter.respond_to?(:debugging?)

      Facter.debugging?
    end

    def empty_message_error(msg)
      invoker = caller(1..1).first.slice(/.*:\d+/)
      @@logger.warn "#{self.class}#debug invoked with invalid message #{msg.inspect}:#{msg.class} at #{invoker}"
    end
  end
end

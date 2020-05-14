# frozen_string_literal: true

require 'logger'

module Facter
  RED = 31
  GREEN = 32
  YELLOW = 33
  CYAN = 36

  DEFAULT_LOG_LEVEL = :warn

  class Log
    @@legacy_logger = nil
    @@logger = MultiLogger.new([])
    @@logger.level = :warn
    @@message_callback = nil
    @@has_errors = false

    class << self
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
    end

    def initialize(logged_class)
      determine_callers_name(logged_class)
    end

    def self.add_legacy_logger(output)
      return if @@legacy_logger

      @@legacy_logger = Logger.new(output)
      @@legacy_logger.level = DEFAULT_LOG_LEVEL
      set_format_for_legacy_logger
      @@logger.add_logger(@@legacy_logger)
    end

    def determine_callers_name(sender_self)
      @class_name = case sender_self
                    when String
                      sender_self
                    when Class
                      sender_self.name
                    when Module
                      sender_self.name
                    else # when class is singleton
                      sender_self.class.name
                    end
    end

    def self.set_format_for_legacy_logger
      @@legacy_logger.formatter = proc do |severity, datetime, _progname, msg|
        datetime = datetime.strftime(@datetime_format || '%Y-%m-%d %H:%M:%S.%6N ')
        "[#{datetime}] #{severity} #{msg} \n"
      end
    end

    def debug(msg)
      return unless debugging_active?

      if msg.nil? || msg.empty?
        invoker = caller(1..1).first.slice(/.*:\d+/)
        empty_message_error(msg, invoker)
      elsif @@message_callback
        @@message_callback.call(:debug, msg)
      else
        msg = colorize(msg, CYAN) if Options[:color]
        @@logger.debug(@class_name + ' - ' + msg)
      end
    end

    def info(msg)
      msg = colorize(msg, GREEN) if Options[:color]
      @@logger.info(@class_name + ' - ' + msg)
    end

    def warn(msg)
      msg = colorize(msg, YELLOW) if Options[:color]

      @@logger.warn(@class_name + ' - ' + msg)
    end

    def error(msg, colorize = false)
      @@has_errors = true
      msg = colorize(msg, RED) if colorize || Options[:color]
      @@logger.error(@class_name + ' - ' + msg)
    end

    def colorize(msg, color)
      return msg if OsDetector.instance.identifier.eql?(:windows)

      "\e[0;#{color}m#{msg}\e[0m"
    end

    private

    def debugging_active?
      return true unless Facter.respond_to?(:debugging?)

      Facter.debugging?
    end

    def empty_message_error(msg, invoker)
      self.warn "#{self.class}#debug invoked with invalid message #{msg.inspect}:#{msg.class} at #{invoker}"
    end
  end
end

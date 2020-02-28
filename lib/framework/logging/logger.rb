# frozen_string_literal: true

require 'logger'

module Facter
  RED = 31

  class Log
    @@file_logger = Logger.new(File.new("#{ROOT_DIR}/example.log", 'a'))
    @@legacy_logger = nil
    @@logger = MultiLogger.new([@@file_logger])
    @@logger.level = :warn

    def initialize(logged_class)
      determine_callers_name(logged_class)
      set_format_for_file_logger
    end

    def self.add_legacy_logger(output)
      return if @@legacy_logger

      @@legacy_logger = Logger.new(output)
      set_format_for_legacy_logger
      @@logger.add_logger(@@legacy_logger)
    end

    def determine_callers_name(sender_self)
      @class_name = sender_self.class.name != 'Class' ? sender_self.class.name : sender_self.name
    end

    def set_format_for_file_logger
      @@file_logger.formatter = proc do |severity, datetime, _progname, msg|
        datetime = datetime.strftime(@datetime_format || '%Y-%m-%d %H:%M:%S.%6N ')
        "[#{datetime}] #{severity} #{msg} \n"
      end
    end

    def self.set_format_for_legacy_logger
      @@legacy_logger.formatter = proc do |severity, datetime, _progname, msg|
        datetime = datetime.strftime(@datetime_format || '%Y-%m-%d %H:%M:%S.%6N ')
        "[#{datetime}] #{severity} #{msg} \n"
      end
    end

    def self.level=(log_level)
      @@logger.level = log_level
    end

    def self.level
      @@logger.level
    end

    def debug(msg)
      @@logger.debug(@class_name + ' - ' + msg)
    end

    def info(msg)
      @@logger.info(@class_name + ' - ' + msg)
    end

    def warn(msg)
      @@logger.warn(@class_name + ' - ' + msg)
    end

    def error(msg, colorize = false)
      msg = colorize(msg, RED) if colorize && !OsDetector.instance.detect.eql?(:windows)
      @@logger.error(@class_name + ' - ' + msg)
    end

    def colorize(msg, color)
      "\e[#{color}m#{msg}\e[0m"
    end
  end
end

# frozen_string_literal: true

module Facter
  RED = 31

  class Log
    @@file_logger = Logger.new(File.new("#{ROOT_DIR}/example.log", 'a'))
    @@legacy_logger = LegacyLogger.new
    @@logger = MultiLogger.new([@@legacy_logger, @@file_logger])
    @@logger.level = :warn

    def initialize(logged_class)
      determine_callers_name(logged_class)
      set_format_for_file_logger
      set_format_for_stdout
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

    def set_format_for_stdout
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
      @@logger.debug(@class_name + ' --- ' + msg)
    end

    def info(msg)
      @@logger.info(@class_name + ' --- ' + msg)
    end

    def warn(msg)
      @@logger.warn(@class_name + ' --- ' + msg)
    end

    def error(msg, colorize = false)
      msg = colorize(msg, RED) if colorize
      @@logger.error(@class_name + ' --- ' + msg)
    end

    def colorize(msg, color)
      "\e[#{color}m#{msg}\e[0m"
    end
  end
end

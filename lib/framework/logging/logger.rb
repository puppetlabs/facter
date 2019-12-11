# frozen_string_literal: true

module Facter
  class Log
    def initialize
      file_logger = Logger.new(File.new("#{ROOT_DIR}/example.log", 'a'))
      legacy_logger = LegacyLogger.new

      @logger = MultiLogger.new([legacy_logger, file_logger])
      @logger.level = :info
    end

    def info(msg)
      @logger.info(msg)
    end

    def debug(msg)
      @logger.debug(msg)
    end

    def error(msg)
      @logger.error(msg)
    end
  end
end

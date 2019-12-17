# frozen_string_literal: true

module Facter
  class LegacyLogger
    def initialize
      @stdout_logger = Logger.new(STDOUT)
      @stderr_logger = Logger.new(STDERR)
    end

    def level=(value)
      @stdout_logger.level = @stderr_logger.level = value
    end

    def formatter=(format)
      @stdout_logger.formatter = format
      @stderr_logger.formatter = format
    end

    def info(msg)
      @stdout_logger.info(msg)
    end

    def debug(msg)
      @stderr_logger.debug(msg)
    end

    def error(msg)
      @stderr_logger.error(msg)
    end
  end
end

# frozen_string_literal: true

# require 'logging'
#
# stdout_appender = Logging.appenders.stdout(
#   'stdout',
#   layout: Logging.layouts.pattern(
#     pattern: '[%d] %-5l %c: %m\n',
#     color_scheme: 'bright'
#   )
# )
#
# file_appender = Logging.appenders.file(
#   'facter.log',
#   layout: Logging.layouts.pattern(
#     pattern: '[%d] %-5l %c: %m\n',
#     color_scheme: 'bright'
#   )
# )

# Logging.logger.root.appenders = stdout_appender, file_appender
# Logging.logger.root.level = :info

require 'logger'
require "#{ROOT_DIR}/lib/utils/multilogger"


# logger.debug "Debug message"
# logger.info "Test message"

class Lg
  def initialize
    file_logger = Logger.new(File.new("#{ROOT_DIR}/example.log", 'a'))
    stdout_logger = Logger.new(STDOUT)

    @logger = MultiLogger.new([stdout_logger, file_logger])
  end

  def debug(msg)
    @logger.debug(msg)
  end
end

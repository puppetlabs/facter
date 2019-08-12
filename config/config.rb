# frozen_string_literal: true

require 'pathname'
require 'logging'

FACTER_VERSION = '0.0.1'
ROOT_DIR      = Pathname.new(File.expand_path('..', __dir__)) unless defined?(ROOT_DIR)
HELP_FILE     = ROOT_DIR.join('help.txt')

# configure logger

stdout_appender = Logging.appenders.stdout(
  'stdout',
  layout: Logging.layouts.pattern(
    pattern: '[%d] %-5l %c: %m\n',
    color_scheme: 'bright'
  )
)

file_appender = Logging.appenders.file(
  'facter.log',
  layout: Logging.layouts.pattern(
    pattern: '[%d] %-5l %c: %m\n',
    color_scheme: 'bright'
  )
)

Logging.logger.root.appenders = stdout_appender, file_appender
Logging.logger.root.level = :info

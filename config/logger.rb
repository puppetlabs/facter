# frozen_string_literal: true

require 'logging'

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

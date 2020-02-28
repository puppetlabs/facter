# frozen_string_literal: true

module Facter
  module OptionsValidator
    INVALID_PAIRS_RULES = { '--color' => '--no-color',
                            '--json' => ['--no-json', '-y', '--yaml', '--hocon'],
                            '--yaml' => ['--no-yaml', '-j', '--hocon'],
                            '--hocon' => '--no-hocon',
                            '-j' => ['--no-json', '--hocon'],
                            '-y' => ['--no-yaml', '-j', '--hocon'],
                            '--puppet' => ['--no-puppet', '--no-ruby', '--no-custom-facts'],
                            '-p' => ['--no-puppet', '--no-ruby', '--no-custom-facts'],
                            '--no-external-facts' => '--external-dir',
                            '--custom-dir' => ['--no-custom-facts', '--no-ruby'] }.freeze
    DUPLICATED_OPTIONS_RULES = { '-j' => '--json', '-y' => '--yaml', '-p' => '--puppet', '-h' => '--help',
                                 '-v' => '--version', '-l' => '--log-level', '-d' => '--debug',
                                 '-c' => '--config' }.freeze
    LOG_LEVEL = %i[none trace debug info warn error fatal].freeze

    def self.validate(options)
      DUPLICATED_OPTIONS_RULES.each do |key, value|
        if options.include?(key) && options.include?(value)
          write_error_and_exit("option #{value} cannot be specified more than once.")
        end
      end

      INVALID_PAIRS_RULES.each do |key, value|
        common_values = [value].flatten & options
        if options.include?(key) && common_values.any?
          write_error_and_exit("#{key} and #{common_values.first} options conflict: please specify only one.")
        end
      end
    end

    def self.write_error_and_exit(message)
      Options.augment_with_priority_options!(is_cli: true)
      log = Facter::Log.new(self)
      log.error(message, true)
      Cli.start(['--help'])
      exit 1
    end
  end
end

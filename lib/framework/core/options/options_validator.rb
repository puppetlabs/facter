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
      log = Facter::Log.new(self)
      log.error(message, true)
      Facter::Cli.start(['--help'])

      exit 1
    end

    def self.validate_configs(options)
      conflicting_configs(options).each do |op|
        next unless op.values[0] && op.values[1]

        message = "#{op.keys[0]} and #{op.keys[1]} options conflict: please specify only one"
        write_error_and_exit(message)
      end
      validate_log_options(options)
    end

    def self.conflicting_configs(options)
      no_ruby = !options[:ruby]
      no_custom_facts = !options[:custom_facts]
      puppet = options[:puppet]
      custom_dir = options[:custom_dir].nil? ? false : options[:custom_dir].any?
      external_dir = options[:external_dir].nil? ? false : options[:external_dir].any?

      [
        { 'no-ruby' => no_ruby, 'custom-dir' => custom_dir },
        { 'no-external-facts' => !options[:external_facts], 'external-dir' => external_dir },
        { 'no-custom-facts' => no_custom_facts, 'custom-dir' => custom_dir },
        { 'no-ruby' => no_ruby, 'puppet' => puppet },
        { 'no-custom-facts' => no_custom_facts, 'puppet' => puppet }
      ]
    end

    def self.validate_log_options(options)
      # TODO: find a better way to do this
      return if options[:debug] == true && options[:log_level] == :debug
      return if options[:verbose] == true && options[:log_level] == :info

      return unless [options[:debug],
                     options[:verbose],
                     options[:log_level] != Facter::DEFAULT_LOG_LEVEL]
                    .count(true) > 1

      message = 'debug, verbose, and log-level options conflict: please specify only one.'
      write_error_and_exit(message)
    end
  end
end

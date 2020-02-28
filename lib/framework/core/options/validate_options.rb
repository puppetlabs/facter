# frozen_string_literal: true

module Facter
  module ValidateOptions
    def validate_configs
      conflicting_configs.each do |op|
        next unless op.values[0] && op.values[1]

        message = "#{op.keys[0]} and #{op.keys[1]} options conflict: please specify only one"
        raise_error(message)
      end
      validate_log_options
    end

    private

    def conflicting_configs
      no_ruby = !@options[:ruby]
      no_custom_facts = !@options[:custom_facts]
      puppet = @options[:puppet]
      custom_dir = @options[:custom_dir].nil? ? false : @options[:custom_dir].any?
      external_dir = @options[:external_dir].nil? ? false : @options[:external_dir].any?

      [
        { 'no-ruby' => no_ruby, 'custom-dir' => custom_dir },
        { 'no-external-facts' => !@options[:external_facts], 'external-dir' => external_dir },
        { 'no-custom-facts' => no_custom_facts, 'custom-fir' => custom_dir },
        { 'no-ruby' => no_ruby, 'puppet' => puppet },
        { 'no-custom-facts' => no_custom_facts, 'puppet' => puppet }
      ]
    end

    def validate_log_options
      return unless [@options[:debug],
                     @options[:verbose],
                     @options[:log_level] != Facter::DefaultOptions::DEFAULT_LOG_LEVEL]
                    .count(true) > 1

      raise_error('debug, verbose, and log-level options conflict: please specify only one.')
    end

    def raise_error(message)
      OptionsValidator.write_error_and_exit(message) if @options[:is_cli]
      log = Facter::Log.new(self)
      log.error(message, true)
      raise ArgumentError, message
    end
  end
end

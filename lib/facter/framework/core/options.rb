# frozen_string_literal: true

module Facter
  class Options
    class << self
      def cli?
        OptionStore.cli
      end

      def get
        OptionStore.all
      end

      def [](key)
        OptionStore.send(key.to_sym)
      end

      def []=(key, value)
        OptionStore.send("#{key}=".to_sym, value)
      end

      def custom_dir?
        OptionStore.custom_dir && OptionStore.custom_facts
      end

      def custom_dir
        [OptionStore.custom_dir].flatten
      end

      def external_dir?
        OptionStore.external_dir && OptionStore.external_facts
      end

      def external_dir
        OptionStore.external_dir
      end

      def init
        OptionStore.cli = false
        ConfigFileOptions.init
        store(ConfigFileOptions.get)
      end

      def init_from_cli(cli_options = {})
        Facter::OptionStore.cli = true
        Facter::OptionStore.show_legacy = false
        Facter::OptionStore.trace = cli_options[:trace]
        OptionStore.set(:config, cli_options[:config])
        ConfigFileOptions.init(cli_options[:config])
        store(ConfigFileOptions.get)
        store(cli_options)

        Facter::OptionsValidator.validate_configs(get)
      end

      def store(options)
        options.each do |key, value|
          value = munge_option(key, value)
          OptionStore.set(key, value)
        end
      end

      private

      def munge_option(key, value)
        return value unless key.to_sym == :log_level

        case value.to_sym
        when :log_level
          ''
        when :none
          'unknown'
        else
          value
        end
      end
    end
  end
end

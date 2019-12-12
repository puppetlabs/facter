# frozen_string_literal: true

module Facter
  module ConfigFileOptions
    def augment_with_config_file_options!(config_path)
      conf_reader = Facter::ConfigReader.new(config_path)

      augment_config_path(config_path)
      augment_cli(conf_reader.cli)
      augment_custom(conf_reader.global)
      augment_external(conf_reader.global)
      augment_ruby(conf_reader.global)
      augment_facts(conf_reader.ttls)
    end

    private

    def augment_config_path(config_path)
      @options[:config] = config_path
    end

    def augment_cli(file_cli_conf)
      return unless file_cli_conf

      @options[:debug] = file_cli_conf['debug'] unless file_cli_conf['debug'].nil?
      @options[:trace] = file_cli_conf['trace'] unless file_cli_conf['trace'].nil?
      @options[:verbose] = file_cli_conf['verbose'] unless file_cli_conf['verbose'].nil?
      @options[:log_level] = file_cli_conf['log-level'].to_sym unless file_cli_conf['log-level'].nil?
    end

    def augment_custom(file_global_conf)
      return unless file_global_conf

      @options[:custom_facts] = !file_global_conf['no-custom-facts'] unless file_global_conf['no-custom-facts'].nil?
      @options[:custom_dir] = file_global_conf['custom-dir'] unless file_global_conf['custom-dir'].nil?
    end

    def augment_external(global_conf)
      return unless global_conf

      @options[:external_facts] = !global_conf['no-external-facts'] unless global_conf['no-external-facts'].nil?
      @options[:external_dir] = global_conf['external-dir'] unless global_conf['external-dir'].nil?
    end

    def augment_ruby(global_conf)
      return unless global_conf

      @options[:ruby] = !global_conf['no-ruby'] unless global_conf['no-ruby'].nil?
    end

    def augment_facts(ttls)
      blocked_facts = Facter::BlockList.instance.blocked_facts
      @options[:blocked_facts] = blocked_facts unless blocked_facts.nil?

      @options[:ttls] = ttls unless ttls.nil?
    end
  end
end

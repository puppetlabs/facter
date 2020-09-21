# frozen_string_literal: true

module Facter
  class ConfigFileOptions
    class << self
      def init(config_path = nil)
        @options = {}
        Facter::ConfigReader.init(config_path)

        augment_config_path(config_path)

        augment_all
      end

      def get
        @options || {}
      end

      private

      def augment_all
        if Options.cli?
          augment_cli(Facter::ConfigReader.cli)
          augment_ruby(Facter::ConfigReader.global)
        end
        augment_custom(Facter::ConfigReader.global)
        augment_external(Facter::ConfigReader.global)
        augment_show_legacy(Facter::ConfigReader.global)
        augment_facts(Facter::ConfigReader.ttls, Facter::ConfigReader.fact_groups)
      end

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

        if Options.cli?
          unless file_global_conf['no-custom-facts'].nil?
            @options[:no_custom_facts] = file_global_conf['no-custom-facts']
          end
        end

        @options[:custom_dir] = file_global_conf['custom-dir'] unless file_global_conf['custom-dir'].nil?
        @options[:config_file_custom_dir] = @options[:custom_dir] || []
      end

      def augment_external(global_conf)
        return unless global_conf

        if Options.cli?
          @options[:no_external_facts] = global_conf['no-external-facts'] unless global_conf['no-external-facts'].nil?
        end

        @options[:external_dir] = [global_conf['external-dir']].flatten unless global_conf['external-dir'].nil?
        @options[:config_file_external_dir] = @options[:external_dir] || []
      end

      def augment_ruby(global_conf)
        return unless global_conf

        @options[:no_ruby] = global_conf['no-ruby'].nil? ? false : global_conf['no-ruby']
      end

      def augment_show_legacy(global_conf)
        return unless global_conf

        @options[:show_legacy] = global_conf['show-legacy'] unless global_conf['show-legacy'].nil?
      end

      def augment_facts(ttls, groups)
        fact_groups = Facter::FactGroups.new

        @options[:blocked_facts] = fact_groups.blocked_facts unless fact_groups.blocked_facts.nil?
        @options[:block_list] = fact_groups.block_list
        @options[:ttls] = ttls unless ttls.nil?

        f_groups = fact_groups.groups || {}
        f_groups = groups.merge(f_groups) unless groups.nil?
        @options[:fact_groups] = f_groups
      end
    end
  end
end

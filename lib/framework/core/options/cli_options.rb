# frozen_string_literal: true

module Facter
  module CliOptions
    def augment_with_cli_options!
      cli_conf = @conf_reade.cli

      return unless cli_conf

      augment_cli(cli_conf)
    end

    private

    def augment_cli(cli_conf)
      @options[:debug] = cli_conf['debug'] unless @options[:debug]
      @options[:trace] = cli_conf['trace'] unless @options[:trace]
      @options[:verbose] = cli_conf['verbose'] unless @options[:verbose]
      @options[:log_level] = cli_conf['log-level'] unless @options[:log_level]
    end
  end
end

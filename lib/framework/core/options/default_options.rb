# frozen_string_literal: true

module Facter
  module DefaultOptions
    def augment_with_defaults!
      cli_defaults
      global_defaults
    end

    private

    def cli_defaults
      @options[:debug] = false if @options[:debug].nil?
      @options[:trace] = false if @options[:trace].nil?
      @options[:verbose] = false if @options[:verbose].nil?
      @options[:log_level] = 'error' unless @options[:log_level]
    end

    def global_defaults
      @options[:custom_facts] = true if @options[:custom_facts].nil?
      @options[:external_facts] = true if @options[:external_facts].nil?
      @options[:ruby] = true if @options[:ruby].nil?
    end
  end
end

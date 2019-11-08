# frozen_string_literal: true

module Facter
  module GlobalOptions
    def augment_with_global_options!
      global_conf = @conf_reade.global

      return unless global_conf

      augment_global(global_conf)
    end

    private

    def augment_global(global_conf)
      @options[:external_dir] = global_conf['external-dir'] unless @options[:external_dir]
      @options[:custom_dir] = global_conf['custom-dir'] unless @options[:custom_dir]
      @options[:no_external_facts] = global_conf['no-external-facts'] unless @options[:no_external_facts]
      @options[:no_custom_facts] = global_conf['no-custom-facts'] unless @options[:no_custom_facts]
      @options[:no_ruby] = global_conf['no-ruby'] unless @options[:no_ruby]
    end
  end
end

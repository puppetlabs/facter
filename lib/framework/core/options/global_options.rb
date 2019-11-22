# frozen_string_literal: true

module Facter
  module GlobalOptions
    def augment_with_global_options!
      global_conf = @conf_reade.global

      return unless global_conf

      augment_ruby(global_conf)
      augment_custom(global_conf)
      augment_external(global_conf)
    end

    private

    def augment_ruby(global_conf)
      @options[:no_ruby] = global_conf['no-ruby'] unless @options[:no_ruby]
    end

    def augment_custom(global_conf)
      @options[:custom_facts] = !global_conf['no-custom-facts'] if @options[:custom_facts].nil?
      @options[:custom_dir] = global_conf['custom-dir'] unless @options[:custom_dir]
    end

    def augment_external(global_conf)
      @options[:external_facts] = !global_conf['no-external-facts'] if @options[:external_facts].nil?
      @options[:external_dir] = global_conf['external-dir'] unless @options[:external_dir]
    end
  end
end

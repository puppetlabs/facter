# frozen_string_literal: true

module Facter
  class Options
    include Facter::DefaultOptions
    include Facter::ConfigFileOptions
    include Facter::PriorityOptions
    include Facter::HelperOptions

    include Singleton

    attr_accessor :priority_options

    def initialize
      @options = {}
      @priority_options = {}
    end

    def refresh(user_query = [])
      @user_query = user_query
      initialize_options

      @options
    end

    def get
      @options
    end

    def [](option)
      @options.fetch(option, nil)
    end

    def custom_dir?
      @options[:custom_dir] && @options[:custom_facts]
    end

    def custom_dir
      @options[:custom_dir]
    end

    def external_dir?
      @options[:external_dir] && @options[:external_facts]
    end

    def external_dir
      @options[:external_dir]
    end

    def self.method_missing(name, *args, &block)
      Facter::Options.instance.send(name.to_s, *args, &block)
    rescue NoMethodError
      super
    end

    def self.respond_to_missing?(name, include_private) end

    private

    def initialize_options
      augment_with_defaults!
      augment_with_to_hash_defaults! if @priority_options[:to_hash]
      augment_with_config_file_options!(@priority_options[:config])
      augment_with_priority_options!(@priority_options)
      augment_with_helper_options!(@user_query)
    end
  end
end

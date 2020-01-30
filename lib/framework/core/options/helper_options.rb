# frozen_string_literal: true

module Facter
  module HelperOptions
    def augment_with_helper_options!(user_query)
      @options[:user_query] = true if user_query.any?

      if @options[:ruby] == false
        @options[:custom_facts] = false
        @options[:blocked_facts] = ['ruby'].concat(@options[:blocked_facts] || [])
      end

      # convert array or string to array
      @options[:external_dir] = [*@options[:external_dir]] unless @options[:external_dir].nil?

      @options[:log_level] = log_level || :unknown
    end

    private

    def log_level
      return :debug if @options[:debug]
      return :trace if @options[:trace]
    end
  end
end

# frozen_string_literal: true

module Facter
  module HelperOptions
    def augment_with_query_options!(user_query)
      @options[:user_query] = true if user_query.any?
      @options[:custom_facts] = false if @options[:ruby] == false
      @options[:external_dir] = array_or_string_to_array(@options[:external_dir])
    end

    private

    def array_or_string_to_array(option_external_dir)
      external_dirs = [] << option_external_dir
      external_dirs.flatten!
    end
  end
end

# frozen_string_literal: true

module Facter
  module HelperOptions
    def augment_with_query_options!(user_query)
      @options[:user_query] = true if user_query.any?
      @options[:custom_facts] = false if @options[:ruby] == false

      # convert array or string to array
      @options[:external_dir] = [*@options[:external_dir]] unless @options[:external_dir].nil?
    end
  end
end

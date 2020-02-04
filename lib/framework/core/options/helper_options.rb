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

      @options[:log_level] = log_level || @options[:log_level]
      validate_log_level
      LegacyFacter.trace(@options[:trace])
    end

    private

    def log_level
      :debug if @options[:debug] || @options[:log_level] == :trace
    end

    def validate_log_level
      if @options[:log_level].empty?
        OptionsValidator.write_error_and_exit('the required argument for option'\
                                                            " '--log-level' is missing")
      end
      unless OptionsValidator::LOG_LEVEL.include?(
        @options[:log_level]
      )
        OptionsValidator.write_error_and_exit("invalid log level #{@options[:log_level]}  : expected none, trace,"\
                                                                                ' debug, info, warn, error, or fatal.')
      end
    end
  end
end

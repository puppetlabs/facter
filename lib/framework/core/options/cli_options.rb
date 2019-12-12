# frozen_string_literal: true

module Facter
  module CliOptions
    def augment_with_cli_options!(cli_options)
      cli_options.each do |key, val|
        @options[key.to_sym] = val
      end
    end
  end
end

# frozen_string_literal: true

module Facter
  module PriorityOptions
    def augment_with_priority_options!(priority_options)
      priority_options.each do |key, val|
        @options[key.to_sym] = val
        @options[key.to_sym] = '' if key == 'log_level' && val == 'log_level'
      end
    end
  end
end

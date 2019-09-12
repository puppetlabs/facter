# frozen_string_literal: true

module Facter
  class FormatterFactory
    def self.build(options)
      return Facter::JsonFactFormatter.new if options[:json]
      return Facter::YamlFactFormatter.new if options[:yaml]

      Facter::HoconFactFormatter.new
    end
  end
end

# frozen_string_literal: true

module Facter
  class OptionsAugmenter
    include Facter::CliOptions
    include Facter::GlobalOptions
    include Facter::FactsOptions
    include Facter::HelperOptions
    include Facter::DefaultOptions

    attr_reader :options

    def initialize(options)
      @options = options.dup
      @conf_reade = Facter::ConfigReader.new(@options[:config])
    end
  end
end

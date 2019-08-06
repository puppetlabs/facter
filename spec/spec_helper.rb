# frozen_string_literal: true

require 'coveralls'
Coveralls.wear!

require 'bundler/setup'
require_relative '../lib/fact_loader'
require_relative '../lib/facts/linux/network_interface'
require_relative 'facter/fact_loader_test'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

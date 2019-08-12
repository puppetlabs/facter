# frozen_string_literal: true

require 'coveralls'
Coveralls.wear!

require 'open3'
require 'thor'

require 'bundler/setup'
require_relative '../lib/fact_loader'
require_relative '../lib/facts/linux/network_interface'
require_relative '../lib/resolvers/base_resolver'
require_relative '../lib/resolvers/linux/os_resolver'
require_relative '../lib/query_parser'
require_relative '../lib/models/loaded_fact'
require_relative '../lib/models/fact_collection'
require_relative '../lib/fact_formatter'

require_relative '../lib/facts/linux/os/name'
require_relative '../lib/facts/linux/os/family'

# Configure SimpleCov
SimpleCov.start do
  track_files 'lib/**/*.rb'
  add_filter 'spec'
end

default_coverage = 8
SimpleCov.minimum_coverage ENV['COVERAGE'] || default_coverage

# Configure RSpec
RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!
  config.expose_dsl_globally = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

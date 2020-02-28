# frozen_string_literal: true

require 'pathname'

ROOT_DIR = Pathname.new(File.expand_path('..', __dir__)) unless defined?(ROOT_DIR)

ENV['RACK_ENV'] = 'test'

require 'bundler/setup'
require 'coveralls'
Coveralls.wear!

require 'open3'
require 'thor'
require 'fileutils'

require_relative '../lib/resolvers/base_resolver'

Dir[ROOT_DIR.join('spec/mocks/*.rb')].each { |file| require file }

require "#{ROOT_DIR}/lib/facter"
require "#{ROOT_DIR}/lib/framework/cli/cli"

Dir.glob(File.join('./lib/facts', '/**/*/', '*.rb'), &method(:require))
Dir.glob(File.join('./lib/resolvers', '/**/*/', '*.rb'), &method(:require))

# Configure SimpleCov
SimpleCov.start do
  track_files 'lib/**/*.rb'
  add_filter 'spec'
end

default_coverage = 90
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

  config.mock_with :rspec do |mocks|
    # This option should be set when all dependencies are being loaded
    # before a spec run, as is the case in a typical spec helper. It will
    # cause any verifying double instantiation for a class that does not
    # exist to raise, protecting against incorrectly spelt names.
    mocks.verify_doubled_constant_names = true
  end
end

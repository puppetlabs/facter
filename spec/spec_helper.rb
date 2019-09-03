# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'coveralls'
Coveralls.wear!

require 'open3'
require 'thor'
require 'fileutils'

require_relative '../lib/resolvers/base_resolver'
require_relative '../spec/helpers/kernel_mock'
require_relative '../spec/helpers/ffi_library'

require 'pathname'

ROOT_DIR = Pathname.new(File.expand_path('..', __dir__)) unless defined?(ROOT_DIR)

require "#{ROOT_DIR}/lib/utils/file_loader"

Dir.glob(File.join('./lib', '/**/*/', '*.rb'), &method(:require))

# Configure SimpleCov
SimpleCov.start do
  track_files 'lib/**/*.rb'
  add_filter 'spec'
end

default_coverage = 50
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

def load_fixture(filename)
  File.open(File.join('spec', 'fixtures', filename))
end

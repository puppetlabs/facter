# frozen_string_literal: true

require 'pathname'
require_relative 'integration_helper'

ROOT_DIR = Pathname.new(File.expand_path('..', __dir__)) unless defined?(ROOT_DIR)

# prevent facter from loading its spec files as facts
$LOAD_PATH.delete_if { |entry| entry =~ %r{facter/spec} }

ENV['RACK_ENV'] = 'test'

require 'bundler/setup'
require 'facter'

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

    # This option forces the same argument and method existence checks that are
    # performed for object_double are also performed on partial doubles.
    # You should set this unless you have a good reason not to.
    # It defaults to off only for backwards compatibility.

    mocks.verify_partial_doubles = true
  end

  config.after do
    Facter.reset
    Facter.clear
    Facter::OptionStore.reset
  end
end

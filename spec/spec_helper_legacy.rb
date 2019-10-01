# frozen_string_literal: true

require 'bundler/setup'
require 'rspec'
require 'pathname'

ROOT_DIR = Pathname.new(File.expand_path('../', __dir__)) unless defined?(ROOT_DIR)
require "#{ROOT_DIR}/lib/custom_facts/core/file_loader"

require "#{ROOT_DIR}/spec/custom_facts/puppetlabs_spec/verbose"
require "#{ROOT_DIR}/spec/custom_facts/shared_contexts/platform.rb"

require "#{ROOT_DIR}/spec/custom_facts/puppetlabs_spec/files"

# Pathname.glob("#{ROOT_DIR}/spec/factershared_contexts/*.rb") do |file|
#   require file.relative_path_from(Pathname.new(dir))
# end

RSpec.configure do |config|
  # config.mock_with :mocha

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!
  config.expose_dsl_globally = true

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before :each do
    # Ensure that we don't accidentally cache facts and environment
    # between test cases.
    allow(LegacyFacter::Util::Loader).to receive(:load_all)
    LegacyFacter.clear
    LegacyFacter.clear_messages

    # Store any environment variables away to be restored later
    @old_env = {}
    ENV.each_key { |k| @old_env[k] = ENV[k] }
  end

  config.after :each do
    # Restore environment variables after execution of each test
    @old_env.each_pair { |k, v| ENV[k] = v }
    to_remove = ENV.keys.reject { |key| @old_env.include? key }
    to_remove.each { |key| ENV.delete key }
  end
end

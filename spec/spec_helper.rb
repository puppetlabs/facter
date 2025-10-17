# frozen_string_literal: true

require 'pathname'
require 'fileutils'
# Configure test logger
require 'logger'
require 'stringio'
logdest = ENV['FACTER_TEST_LOG'] ? File.new(ENV['FACTER_TEST_LOG'], 'w') : StringIO.new
logger = Logger.new(logdest)

# Configure RSpec
RSpec.configure do |config|
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

  config.before(:all) do
    Facter::Log.class_variable_set(:@@logger, logger) # rubocop:disable Style/ClassVars
  end

  config.before do |test|
    m = test.metadata
    logger.info("*** BEGIN TEST #{m[:file_path]}:#{m[:line_number]}")
  end

  # This will cleanup any files that were created with tmpdir or tmpfile
  require_relative 'custom_facts/puppetlabs_spec/files'
  config.extend PuppetlabsSpec::Files
  config.after do
    PuppetlabsSpec::Files.cleanup
  end
end

# Configure unit vs integration
ROOT_DIR = Pathname.new(File.expand_path('..', __dir__)) unless defined?(ROOT_DIR)
SPEC_DIR = File.join(ROOT_DIR, 'spec')
INTEGRATION_DIR = File.join(ROOT_DIR, 'spec_integration')

unit_tests = ARGV.grep(/spec_integration/).empty?
if unit_tests
  # Normally facter lazily loads facts and resolvers for the specific platform
  # it's running on, because some classes depend on libraries that can't be
  # required on the host running test, like WIN32OLE. So first, mock out
  # platform-specific classes
  Dir[ROOT_DIR.join('spec/mocks/*.rb')].sort.each { |file| require file }

  # Second, require facter
  require 'facter'

  # Third, eagerly load all facts and resolvers
  Dir.glob(File.join('./lib/facter/util', '/**/*/', '*.rb')).sort.each(&method(:require))
  Dir.glob(File.join('./lib/facter/facts', '/**/*/', '*.rb')).sort.each(&method(:require))
  Dir.glob(File.join('./lib/facter/resolvers', '/**/*/', '*.rb')).sort.each(&method(:require))

  # Configure webmock
  require 'webmock/rspec'
  WebMock.disable_net_connect!

  # Unit specific config
  RSpec.configure do |config|
    # Enable flags like --only-failures and --next-failure
    config.example_status_persistence_file_path = '.rspec_status'

    config.before do
      LegacyFacter.clear
      Facter.clear_messages
    end

    config.after do
      Facter::OptionStore.reset
      Facter::ConfigReader.clear
      Facter::ConfigFileOptions.clear
      Facter.instance_variable_set(:@logger, nil)
      Facter::FactLoader.instance.instance_variable_set(:@logger, nil)
      Facter::FactManager.instance.instance_variable_set(:@logger, nil)
    end
  end

  def colorize(str, color)
    "#{color}#{str}#{Facter::RESET}"
  end
else
  require 'facter'

  $LOAD_PATH << INTEGRATION_DIR
  require 'integration_helper'

  # prevent facter from loading its spec files as facts
  $LOAD_PATH.delete_if { |entry| entry == SPEC_DIR }

  # Integration specific config
  RSpec.configure do |config|
    # Enable flags like --only-failures and --next-failure
    config.example_status_persistence_file_path = '.rspec_integration_status'

    # exclude `skip_outside_ci` tests if not running on CI
    config.filter_run_excluding :skip_outside_ci unless ENV['CI']

    config.after do
      Facter::OptionStore.reset
      Facter::ConfigReader.clear
      Facter::ConfigFileOptions.clear

      Facter.reset
      Facter.clear
      LegacyFacter.clear
    end
  end
end

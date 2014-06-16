require 'rubygems'
require 'mocha'
require 'rspec'
require 'facter'
require 'fileutils'
require 'puppetlabs_spec_helper'
require 'pathname'

# load shared_context within this project's spec directory
dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(dir, 'lib')

Pathname.glob("#{dir}/shared_contexts/*.rb") do |file|
  require file.relative_path_from(Pathname.new(dir))
end

module LogSpecOrder
  # Log the spec order to a file, but only if the LOG_SPEC_ORDER environment
  # variable is set.  This could be enabled on Jenkins runs, as it can
  # be used with Nick L.'s bisect script to help identify and debug
  # order-dependent spec failures.
  #
  # jpartlow 2013-07-05: this was in puppet and I pulled it into facter because
  # I was seeing similar ordering issues in the specs...and needed to bisect them :/
  def self.log_spec_order
    if ENV['LOG_SPEC_ORDER']
      File.open("./spec_order.txt", "w") do |logfile|
        RSpec.configuration.files_to_run.each { |f| logfile.puts f }
      end
    end
  end
end

# Executing here rather than after :suite, so that we can get the order output
# even when the issue breaks rspec when specs are first loaded.
LogSpecOrder.log_spec_order

RSpec.configure do |config|
  config.mock_with :mocha

  if Facter::Util::Config.is_windows? && RUBY_VERSION =~ /^1\./
    require 'win32console'
    config.output_stream = $stdout
    config.error_stream = $stderr
    config.formatters.each { |f| f.instance_variable_set(:@output, $stdout) }
  end

  config.before :each do
    # Ensure that we don't accidentally cache facts and environment
    # between test cases.
    Facter::Util::Loader.any_instance.stubs(:load_all)
    Facter.clear
    Facter.clear_messages

    # Store any environment variables away to be restored later
    @old_env = {}
    ENV.each_key {|k| @old_env[k] = ENV[k]}
  end

  config.after :each do
    # Restore environment variables after execution of each test
    @old_env.each_pair {|k, v| ENV[k] = v}
    to_remove = ENV.keys.reject {|key| @old_env.include? key }
    to_remove.each {|key| ENV.delete key }
  end
end

module FacterSpec
  module ConfigHelper
    def given_a_configuration_of(config)
      Facter::Util::Config.stubs(:is_windows?).returns(config[:is_windows])
      Facter::Util::Config.stubs(:external_facts_dir).returns(config[:external_facts_dir] || "data_dir")
    end
  end
end

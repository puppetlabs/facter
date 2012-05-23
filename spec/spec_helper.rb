# Add the projects lib directory to our load path so we can require libraries
# within it easily.
dir = File.expand_path(File.dirname(__FILE__))

SPECDIR = dir
$LOAD_PATH.unshift("#{dir}/../lib")

require 'rubygems'
require 'mocha'
require 'rspec'
require 'facter'
require 'fileutils'
require 'puppetlabs_spec_helper'
require 'pathname'

Pathname.glob("#{dir}/shared_contexts/*.rb") do |file|
  require file.relative_path_from(Pathname.new(dir))
end

RSpec.configure do |config|
  config.mock_with :mocha

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

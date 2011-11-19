dir = File.expand_path(File.dirname(__FILE__))

SPECDIR = dir

def fixture_data(file)
  File.read(File.join(SPECDIR, "fixtures", file))
end


$LOAD_PATH.unshift("#{dir}/")
$LOAD_PATH.unshift("#{dir}/../lib")

require 'rubygems'
require 'mocha'
require 'rspec'
require 'facter'

# load any monkey-patches
Dir["#{dir}/monkey_patches/*.rb"].map { |file| require file }

RSpec.configure do |config|
  config.mock_with :mocha

  # Ensure that we don't accidentally cache facts and environment
  # between test cases.
  config.before :each do
    Facter::Util::Loader.any_instance.stubs(:load_all)
    Facter.clear
    Facter.clear_messages
    @old_env = {}
    ENV.each_key {|k| @old_env[k] = ENV[k]}
  end

  config.after :each do
    @old_env.each_pair {|k, v| ENV[k] = v}
    to_remove = ENV.keys.reject {|key| @old_env.include? key }
    to_remove.each {|key| ENV.delete key }
  end
end

dir = File.expand_path(File.dirname(__FILE__))

SPECDIR = dir

$LOAD_PATH.unshift("#{dir}/")
$LOAD_PATH.unshift("#{dir}/lib")
$LOAD_PATH.unshift("#{dir}/../lib")

module FacterSpec
end

require 'rubygems'
require 'mocha'
require 'rspec'
require 'facter'

require 'facter_spec/files'

# load any monkey-patches
Dir["#{dir}/monkey_patches/*.rb"].map { |file| require file }

RSpec.configure do |config|
  config.mock_with :mocha

  # Ensure that we don't accidentally cache between test cases.
  config.before :each do
    Facter::Util::Loader.any_instance.stubs(:load_all)
    Facter.clear
    Facter.clear_messages
  end

  config.after :each do
    FacterSpec::Files.cleanup
  end
end

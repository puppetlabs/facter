dir = File.expand_path(File.dirname(__FILE__))

SPECDIR = dir

$LOAD_PATH.unshift("#{dir}/")
$LOAD_PATH.unshift("#{dir}/../lib")

require 'rubygems'
require 'mocha'
require 'spec'
require 'facter'

# load any monkey-patches
Dir["#{dir}/monkey_patches/*.rb"].map { |file| require file }

Spec::Runner.configure do |config|
    config.mock_with :mocha
end

dir = File.expand_path(File.dirname(__FILE__))

$LOAD_PATH.unshift("#{dir}/")
$LOAD_PATH.unshift("#{dir}/../lib")

# include any gems in vendor/gems
Dir["#{dir}/../vendor/gems/**"].each do |path| 
    libpath = File.join(path, "lib")
    if File.directory?(libpath)
        $LOAD_PATH.unshift(libpath)
    else
        $LOAD_PATH.unshift(path)
    end
end

require 'mocha'
require 'spec'
require 'facter'

# load any monkey-patches
Dir["#{dir}/monkey_patches/*.rb"].map { |file| require file }

Spec::Runner.configure do |config|
    config.mock_with :mocha
end

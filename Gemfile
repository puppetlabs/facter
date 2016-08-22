source "https://rubygems.org"

gem 'trollop', '>= 2.0.0'

group :development do
  gem 'watchr'
end

group :development, :test do
  gem 'rake'
  gem 'rspec', "~> 2.11.0", :require => false
  gem 'mocha', "~> 0.10.5", :require => false
  gem 'json', "~> 1.7", :platforms => :ruby, :require => false
  gem 'puppetlabs_spec_helper', :require => false
end

gem 'facter', ">= 1.0.0", :path => File.expand_path("..", __FILE__), :require => false

if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end

# vim:ft=ruby

source ENV['GEM_SOURCE'] || "https://rubygems.org"

# C Ruby (MRI) or Rubinius, but NOT Windows
platforms :ruby do
  gem 'watchr', :group => :development
  gem 'pry', :group => :development
  gem 'yard', :group => :development
  gem 'redcarpet', '<= 2.3.0', :group => :development
end

group :development, :test do
  gem 'yarjuf', "~> 1.0"
  gem 'rake', "~> 10.1.0"
  gem 'rspec', "~> 2.11.0"
  gem 'mocha', "~> 0.10.5"
  gem 'json', "~> 1.7", :platforms => :ruby
  gem 'json-schema', :platforms => :ruby
  gem 'puppetlabs_spec_helper'
end

require 'yaml'
data = YAML.load_file(File.join(File.dirname(__FILE__), 'ext', 'project_data.yaml'))
bundle_platforms = data['bundle_platforms']
data['gem_platform_dependencies'].each_pair do |gem_platform, info|
  next if gem_platform =~ /mingw/
  if bundle_deps = info['gem_runtime_dependencies']
    bundle_platform = bundle_platforms[gem_platform] or raise "Missing bundle_platform"
    platform(bundle_platform.intern) do
      bundle_deps.each_pair do |name, version|
        gem(name, version, :require => false)
      end
    end
  end
end

platform(:mingw_19) do
  gem 'win32console', '~> 1.3.2', :require => false
end

mingw = [:mingw]
mingw << :x64_mingw if Bundler::Dsl::VALID_PLATFORMS.include?(:x64_mingw)

platform(*mingw) do
  gem 'ffi', '~> 1.9.5', :require => false
  gem 'win32-dir', '~> 0.4.8', :require => false
  gem 'win32-security', '~> 0.2.5', :require => false
end

gem 'facter', ">= 1.0.0", :path => File.expand_path("..", __FILE__)

if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end

# vim:ft=ruby

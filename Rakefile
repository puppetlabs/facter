# Rakefile for facter

# We need access to the Puppet.version method
$LOAD_PATH.unshift(File.expand_path("lib"))
require 'facter/version'

$LOAD_PATH << File.join(File.dirname(__FILE__), 'tasks')

require 'rubygems'
require 'rspec'
require 'rspec/core/rake_task'
require 'rake'
require 'yaml'

begin
  require 'rcov'
rescue LoadError
end

Dir['tasks/**/*.rake'].each { |t| load t }
Dir['ext/packaging/tasks/**/*'].sort.each { |t| load t }

begin
  @build_defaults ||= YAML.load_file('ext/build_defaults.yaml')
  @packaging_url  = @build_defaults['packaging_url']
  @packaging_repo = @build_defaults['packaging_repo']
rescue
  STDERR.puts "Unable to read the packaging repo info from ext/build_defaults.yaml"
end

namespace :package do
  desc "Bootstrap packaging automation, e.g. clone into packaging repo"
  task :bootstrap do
    if File.exist?("ext/#{@packaging_repo}")
      puts "It looks like you already have ext/#{@packaging_repo}. If you don't like it, blow it away with package:implode."
    else
      cd 'ext' do
        %x{git clone #{@packaging_url}}
      end
    end
  end

  desc "Remove all cloned packaging automation"
  task :implode do
    rm_rf "ext/#{@packaging_repo}"
  end
end

task :default do
  sh %{rake -T}
end

# Aliases for spec
task :tests   => [:test]
task :specs   => [:test]

desc "Run all specs"
RSpec::Core::RakeTask.new(:test) do |t|
  t.pattern ='spec/{unit,integration}/**/*_spec.rb'
  t.fail_on_error = true
end

RSpec::Core::RakeTask.new('spec:rcov') do |t|
  t.pattern ='spec/{unit,integration}/**/*_spec.rb'
  t.fail_on_error = true
  if defined?(Rcov)
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec/*,test/*,results/*,/usr/lib/*,/usr/local/lib/*,gems/*']
  end
end

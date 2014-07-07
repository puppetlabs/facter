# Rakefile for facter

# We need access to the Puppet.version method
$LOAD_PATH.unshift(File.expand_path("lib"))
require 'facter/version'

$LOAD_PATH << File.join(File.dirname(__FILE__), 'tasks')

require 'rake'
Dir['tasks/**/*.rake'].each { |t| load t }

begin
  load File.join(File.dirname(__FILE__), 'ext', 'packaging', 'packaging.rake')
rescue LoadError
end

['rubygems',
'rspec',
'rspec/core/rake_task',
'rcov',].each do |lib|
  begin
    require lib
  rescue LoadError
  end
end


build_defs_file = 'ext/build_defaults.yaml'
if File.exist?(build_defs_file)
  begin
    require 'yaml'
    @build_defaults ||= YAML.load_file(build_defs_file)
  rescue Exception => e
    STDERR.puts "Unable to load yaml from #{build_defs_file}:"
    STDERR.puts e
  end
  @packaging_url  = @build_defaults['packaging_url']
  @packaging_repo = @build_defaults['packaging_repo']
  raise "Could not find packaging url in #{build_defs_file}" if @packaging_url.nil?
  raise "Could not find packaging repo in #{build_defs_file}" if @packaging_repo.nil?

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
end

task :default do
  sh %{rake -T}
end

if defined?(RSpec::Core::RakeTask)
  desc "Run all specs"
  RSpec::Core::RakeTask.new do |t|
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
end

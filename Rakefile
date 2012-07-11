# Rakefile for facter

$: << File.expand_path('lib')
$LOAD_PATH << File.join(File.dirname(__FILE__), 'tasks')

require 'rubygems'
require 'rspec'
require 'rspec/core/rake_task'
begin
  require 'bundler/gem_tasks'
  task :gem => :build
rescue LoadError
  puts "The gem `bundler` is not installed, without it I don't know how to run the 'gem' task"
end
begin
  require 'rcov'
rescue LoadError
end

Dir['tasks/**/*.rake'].each { |t| load t }

require 'rake'

def get_version
  `git describe`.strip
end

# :build_environment and :tar are mostly borrowed from puppet-dashboard Rakefile
task :build_environment do
  unless ENV['FORCE'] == '1'
    modified = `git status --porcelain | sed -e '/^\?/d'`
    if modified.split(/\n/).length != 0
      puts <<-HERE
!! ERROR: Your git working directory is not clean. You must
!! remove or commit your changes before you can create a package:

#{`git status | grep '^#'`.chomp}

!! To override this check, set FORCE=1 -- e.g. `rake package:deb FORCE=1`
      HERE
      raise
    end
  end
end

desc "Create a release .tar.gz"
task :tar => :build_environment do
  name = "facter"
  rm_rf 'pkg/tar'
  temp=`mktemp -d -t tmpXXXXXX`.strip!
  version = get_version
  base = "#{temp}/#{name}-#{version}/"
  mkdir_p base
  sh "git checkout-index -af --prefix=#{base}"
  mkdir_p "pkg/tar"
  sh "tar -C #{temp} -pczf #{temp}/#{name}-#{version}.tar.gz #{name}-#{version}"
  mv "#{temp}/#{name}-#{version}.tar.gz", "pkg/tar"
  rm_rf temp
  puts "Tarball is pkg/tar/#{name}-#{version}.tar.gz"
end

task :package => :tar
task :gem => :build

task :default do
  sh %{rake -T}
end

# Aliases for spec
task :test    => [:spec]
task :tests   => [:spec]
task :specs   => [:spec]

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

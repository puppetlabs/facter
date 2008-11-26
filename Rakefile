# Rakefile for facter

begin 
    require 'rake/reductive'
rescue LoadError
    $stderr.puts "You must have the Reductive build library in your RUBYLIB."
    exit(14)
end

project = Rake::RedLabProject.new("facter") do |p|
    p.summary = "Facter collects Operating system facts."
    p.description = <<-EOF
      Facter is a module for collecting simple facts about a host 
      Operating system.
    EOF

    p.filelist = [
        'install.rb',
        '[A-Z]*',
        'bin/**/*', 
        'lib/facter.rb',
        'lib/**/*.rb', 
        'test/**/*.rb',
        'spec/**/*',
        'conf/**/*',
        'documentation/**/*',
        'etc/*'
    ]

end

project.mkgemtask do |gem|
    gem.require_path = 'lib'                         # Use these for libraries.

    gem.bindir = "bin"                               # Use these for applications.
    gem.executables = ["facter"]
    gem.default_executable = "facter"

    gem.author = "Luke Kanies"
end

task :archive do
    raise ArgumentError, "You must specify the archive name by setting ARCHIVE; e.g., ARCHIVE=1.5.1rc1" unless archive = ENV["ARCHIVE"]

    sh "git archive --format=tar  --prefix=facter-#{archive}/ HEAD | gzip -c > facter-#{archive}.tgz"
end

namespace :ci do

  desc "Run the CI prep tasks"
  task :prep do
    require 'rubygems'
    gem 'ci_reporter'
    require 'ci/reporter/rake/rspec'
    require 'ci/reporter/rake/test_unit'
    ENV['CI_REPORTS'] = 'results'
  end

  desc "Run CI RSpec tests"
  task :spec => [:prep, 'ci:setup:rspec'] do
     sh "cd spec; rake all; exit 0"
  end

end


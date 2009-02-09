# Rakefile for facter

$LOAD_PATH << File.join(File.dirname(__FILE__), 'tasks')

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

desc "Send patch information to the puppet-dev list"
task :mail_patches do
    if Dir.glob("00*.patch").length > 0
        raise "Patches already exist matching '00*.patch'; clean up first"
    end

    unless %x{git status} =~ /On branch (.+)/
        raise "Could not get branch from 'git status'"
    end
    branch = $1
    
    unless branch =~ %r{^([^\/]+)/([^\/]+)/([^\/]+)$}
        raise "Branch name does not follow <type>/<parent>/<name> model; cannot autodetect parent branch"
    end

    type, parent, name = $1, $2, $3

    # Create all of the patches
    sh "git format-patch -C -M -s -n #{parent}..HEAD"

    # And then mail them out.

    # If we've got more than one patch, add --compose
    if Dir.glob("00*.patch").length > 1
        compose = "--compose"
    else
        compose = ""
    end

    # Now send the mail.
    sh "git send-email #{compose} --no-chain-reply-to --no-signed-off-by-cc --suppress-from --no-thread --to puppet-dev@googlegroups.com 00*.patch"

    # Finally, clean up the patches
    sh "rm 00*.patch"
end

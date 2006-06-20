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
        'lib/**/*.rb', 
        'test/**/*.rb',
        'doc/**/*',
        'etc/*'
    ]

    p.epmhosts = %w{culain}
    p.rpmhost = "fedora1"
end

project.mkgemtask do |gem|
    gem.require_path = 'lib'                         # Use these for libraries.

    gem.bindir = "bin"                               # Use these for applications.
    gem.executables = ["facter"]
    gem.default_executable = "facter"
end

if project.has?(:epm)
    project.mkepmtask do |task|
        task.bins = FileList.new("bin/facter")
        task.rubylibs = FileList.new('lib/**/*')          
    end
end
# $Id$

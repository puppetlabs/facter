module Facter
  module Application
    def self.run(argv)
      require 'facter/util/trollop'
      require 'facter'

      options = Trollop::options do
        version "#{Facter.version}"
        banner <<-EOS
SYNOPSIS
========
Collect and display facts about the system.

DESCRIPTION
===========
Collect and display facts about the current system. The library behind
Facter is easy to expand, making Facter an easy way to collect
information about a system from within the shell or within Ruby.

If no facts are specifically asked for, then all facts will be returned.

EXAMPLE
=======
  facter kernel

AUTHOR
======
Luke Kanies

COPYRIGHT
=========
Copyright (c) 2011-2012 Puppet Labs, Inc Licensed under the Apache 2.0
license

USAGE
=====

EOS
        opt :yaml, "Emit facts in YAML format."
        opt :json, "Emit facts in JSON format."
        opt :timing, "Enable timing."
        opt :trace, "Enable backtraces."
        opt :debug, "Enable debugging."
        opt :puppet, "Load the Puppet libraries, thus allowing Facter to load Puppet-specific facts."
        opt :version, "Print the version and exit."
      end

      # Accept fact names to return from the command line
      names = argv

      if options[:debug]
        Facter.debugging(1)
      end

      if options[:timing]
        Facter.timing(1)
      end

      if options[:puppet]
        self.load_puppet
      end

      # Create the facts hash that is printed to standard out.
      unless names.empty?
        facts = {}
        names.each do |name|
          begin
            facts[name] = Facter.value(name)
          rescue => error
            $stderr.puts "Could not retrieve #{name}: #{error}"
            exit 10
          end
        end
      end

      # Print everything if they didn't ask for specific facts.
      facts ||= Facter.to_hash

      # Print the facts as YAML and exit
      if options[:yaml]
        require 'yaml'
        puts YAML.dump(facts)
        exit(0)
      end

      # Print the facts as JSON and exit
      if options[:json]
        begin
          require 'rubygems'
          require 'json'
          puts JSON.dump(facts)
          exit(0)
        rescue LoadError
          $stderr.puts "You do not have JSON support in your version of Ruby. JSON output disabled"
          exit(1)
        end
      end


      # Print the value of a single fact, otherwise print a list sorted by fact
      # name and separated by "=>"
      if facts.length == 1
        if value = facts.values.first
          puts value
        end
      else
        facts.sort_by{ |fact| fact.first }.each do |name,value|
          puts "#{name} => #{value}"
        end
      end

    rescue => e
      if options && options[:trace]
        raise e
      else
        $stderr.puts "Error: #{e}"
        exit(12)
      end
    end

    def self.load_puppet
      require 'puppet'
      Puppet.parse_config

      # If you've set 'vardir' but not 'libdir' in your
      # puppet.conf, then the hook to add libdir to $:
      # won't get triggered.  This makes sure that it's setup
      # correctly.
      unless $LOAD_PATH.include?(Puppet[:libdir])
        $LOAD_PATH << Puppet[:libdir]
      end
    rescue LoadError => detail
      $stderr.puts "Could not load Puppet: #{detail}"
    end

  end
end

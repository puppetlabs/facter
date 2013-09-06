module Facter
  module Application

    require 'facter/util/nothing_loader'

    def self.create_directory_loader(dir)
      begin
        Facter::Util::Config.ext_fact_loader = Facter::Util::DirectoryLoader.loader_for(dir)
      rescue Facter::Util::DirectoryLoader::NoSuchDirectoryError => error
        $stderr.puts "Specified external facts directory #{dir} does not exist."
        exit(1)
      end
    end

    def self.create_nothing_loader
      Facter::Util::Config.ext_fact_loader = Facter::Util::NothingLoader.new
    end

    def self.run(argv)
      require 'optparse'
      require 'facter'

      options = parse(argv)

      # Accept fact names to return from the command line
      names = argv

      # Change location of external facts dir
      # Check here for valid ext_dir and exit program

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

    private

    # Parses the given argument array destructively to return an options hash
    # (and possibly perform side effects such as changing settings).
    #
    # @param [Array<String>] argv command line arguments
    # @return [Hash] options hash
    def self.parse(argv)
      options = {}
      parser = OptionParser.new do |opts|
        opts.banner = <<-BANNER
Synopsis
========

Collect and display facts about the system.

Usage
=====

  facter [-d|--debug] [-h|--help] [-p|--puppet] [-v|--version] [-y|--yaml] [-j|--json] [--external-dir DIR] [--no-external-dir] [fact] [fact] [...]

Description
===========

Collect and display facts about the current system.  The library behind
Facter is easy to expand, making Facter an easy way to collect information
about a system from within the shell or within Ruby.

If no facts are specifically asked for, then all facts will be returned.

EXAMPLE
=======
  facter kernel

AUTHOR
======
  Luke Kanies

COPYRIGHT
=========
  Copyright (c) 2011-2012 Puppet Labs, Inc Licensed under the Apache 2.0 license

USAGE
=====
        BANNER
        opts.on("-y",
                "--yaml",
                "Emit facts in YAML format.")   { |v| options[:yaml]   = v }
        opts.on("-j",
                "--json",
                "Emit facts in JSON format.")   { |v| options[:json]   = v }
        opts.on("--trace",
                "Enable backtraces.")  { |v| options[:trace]  = v }
        opts.on("--external-dir DIR",
                "The directory to use for external facts.") { |v| create_directory_loader(v) }
        opts.on("--no-external-dir",
                "Turn off external facts.") { |v| create_nothing_loader }
        opts.on("-d",
                "--debug",
                "Enable debugging.")  { |v| Facter.debugging(1) }
        opts.on("-t",
                "--timing",
                "Enable timing.") { |v| Facter.timing(1) }
        opts.on("-p",
                "--puppet",
                "Load the Puppet libraries, thus allowing Facter to load Puppet-specific facts.") { |v| load_puppet }

        opts.on_tail("-v",
                     "--version",
                     "Print the version and exit.") do
          puts Facter.version
          exit(0)
        end

        opts.on_tail("-h",
                     "--help",
                     "Print this help message.") do
          puts parser
          exit(0)
        end
      end

      parser.parse!(argv)

      options
    rescue OptionParser::InvalidOption => e
      $stderr.puts e.message
      exit(12)
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

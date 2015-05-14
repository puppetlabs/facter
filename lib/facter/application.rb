require 'optparse'
require 'facter'
require 'facter/util/formatter'

module Facter
  module Application

    require 'facter/util/nothing_loader'

    def self.create_directory_loader(dir)
      begin
        Facter::Util::Config.ext_fact_loader = Facter::Util::DirectoryLoader.loader_for(dir)
      rescue Facter::Util::DirectoryLoader::NoSuchDirectoryError => error
        Facter.log_exception(error, "Specified external facts directory #{dir} does not exist.")
        exit(1)
      end
    end

    def self.create_nothing_loader
      Facter::Util::Config.ext_fact_loader = Facter::Util::NothingLoader.new
    end

    def self.run(argv)
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
            Facter.log_exception(error, "Could not retrieve #{name}: #{error.message}")
            exit(10)
          end
        end
      end

      # Print everything if they didn't ask for specific facts.
      facts ||= Facter.to_hash

      output = nil

      if options[:yaml]
        output = Facter::Util::Formatter.format_yaml(facts)
      elsif options[:json]
        output = Facter::Util::Formatter.format_json(facts)
      elsif options[:plaintext]
        output = Facter::Util::Formatter.format_plaintext(facts)
      else
        output = Facter::Util::Formatter.format_plaintext(facts)
      end

      puts output
      exit(0)

    rescue => e
      Facter.log_exception(e)
      exit(12)
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
facter(8) -- Gather system information
======

SYNOPSIS
--------

Collect and display facts about the system.

USAGE
-----

    facter [-h|--help] [-t|--timing] [-d|--debug] [-p|--puppet] [-v|--version]
      [-y|--yaml] [-j|--json] [--plaintext] [--external-dir DIR] [--no-external-dir]
      [fact] [fact] [...]

DESCRIPTION
-----------

Collect and display facts about the current system.  The library behind
Facter is easy to expand, making Facter an easy way to collect information
about a system from within the shell or within Ruby.

If no facts are specifically asked for, then all facts will be returned.

EXAMPLE
-------

Display all facts:

    $ facter
    architecture => amd64
    blockdevices => sda,sr0
    domain => example.com
    fqdn => puppet.example.com
    hardwaremodel => x86_64
    [...]

Display a single fact:

    $ facter kernel
    Linux

Format facts as JSON:

    $ facter --json architecture kernel hardwaremodel
    {
      "architecture": "amd64",
      "kernel": "Linux",
      "hardwaremodel": "x86_64"
    }

AUTHOR
------
  Luke Kanies

COPYRIGHT
---------
  Copyright (c) 2011-2014 Puppet Labs, Inc Licensed under the Apache 2.0 license

OPTIONS
-------
        BANNER
        opts.on("-y",
                "--yaml",
                "Emit facts in YAML format.")   { |v| options[:yaml]   = v }
        opts.on("-j",
                "--json",
                "Emit facts in JSON format.")   { |v| options[:json]   = v }
        opts.on("--plaintext",
                "Emit facts in plaintext format.") { |v| options[:plaintext] = v }
        opts.on("--trace",
                "Enable backtraces.")  { |v| Facter.trace(true) }
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
                "(Deprecated: use `puppet facts` instead) Load the Puppet libraries, thus allowing Facter to load Puppet-specific facts.") do |v|
          load_puppet
        end

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
      Puppet.initialize_settings

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

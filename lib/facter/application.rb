module Facter
  module Application
    def self.run(argv)
      require 'optparse'
      require 'facter'
      require 'yaml'

      options = parse(argv)

      # Accept fact names to return from the command line
      names = argv

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

      # Print the facts as JSON and exit
      if options[:json]
        print_json(facts)
      end

      print_yaml(facts)

    rescue => e
      if options && options[:trace]
        raise e
      else
        $stderr.puts "Error: #{e}"
        exit(12)
      end
    end

    private

    def self.print_json(facts)
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

    def self.print_yaml(facts)
      puts sort_yaml_hash(facts)
      exit(1)
    end

    def self.sort_yaml_hash(obj)
      arr = obj.sort
      out = "---\n"
      arr.each do |element|
        entry = {element[0] => element[1]}
        out += entry.to_yaml.to_a[1..-1].join + "\n"
      end
      out
    end

    def self.parse(argv)
      options = {}
      OptionParser.new do |opts|
        opts.on("-y", "--yaml")   { |v| options[:yaml]   = v }
        opts.on("-j", "--json")   { |v| options[:json]   = v }
        opts.on(      "--trace")  { |v| options[:trace]  = v }
        opts.on("-d", "--debug")  { |v| Facter.debugging(1) }
        opts.on("-t", "--timing") { |v| Facter.timing(1) }
        opts.on("-p", "--puppet") { |v| load_puppet }

        opts.on_tail("-v", "--version") do
          puts Facter.version
          exit(0)
        end

        opts.on_tail("-h", "--help") do
          begin
            require 'rdoc/ri/ri_paths'
            require 'rdoc/usage'
            RDoc.usage # print usage and exit
          rescue LoadError
            $stderr.puts "No help available unless your RDoc has RDoc.usage"
            exit(1)
          rescue => e
            $stderr.puts "fatal: #{e}"
            exit(1)
          end
        end
      end.parse!

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

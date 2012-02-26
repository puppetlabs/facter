module Facter
  module Application
    def self.run(argv)
      require 'optparse'
      require 'facter'

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
          pretty_output(value)
        end
      else
        facter_output(facts)
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

    def self.facter_output(data)
      # Line up equals signs
      size_ordered = data.keys.sort_by {|x| x.length}
      max_var_length = size_ordered[-1].length

      data.sort.each do |e|
        k,v = e
        $stdout.write("\e[33m$#{k}\e[0m")
        indent(max_var_length - k.length, " ")
        $stdout.write(" = ")
        pretty_output(v)
      end
    end

    def self.pretty_output(data, indent = 0)
      case data
      when Hash
        puts "\e[35m{\e[0m"
        indent = indent+1
        data.sort.each do |e|
          k,v = e
          indent(indent)
          $stdout.write "\e[32m\"#{k}\"\e[0m => "
          case v
          when String,TrueClass,FalseClass
            pretty_output(v, indent)
          when Hash,Array
            pretty_output(v, indent)
          end
        end
        indent(indent-1)
        puts "\e[35m}\e[0m#{tc(indent-1)}"
      when Array
        puts "\e[35m[\e[0m"
        indent = indent+1
        data.each do |e|
          indent(indent)
          case e
          when String,TrueClass,FalseClass
            pretty_output(e, indent)
          when Hash,Array
            pretty_output(e, indent)
          end
        end
        indent(indent-1)
        puts "\e[35m]\e[0m#{tc(indent-1)}"
      when TrueClass,FalseClass,Numeric
        puts "\e[36m#{data}\e[0m#{tc(indent)}"
      when String
        puts "\e[32m\"#{data}\"\e[0m#{tc(indent)}"
      end
    end

    def self.tc(indent)
      indent > 0 ? "," : ""
    end

    def self.indent(num, indent = "  ")
      num.times { $stdout.write(indent) }
    end

  end
end

require 'facter/util/text'

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
        opts.on("-y", "--yaml")    { |v| options[:yaml]    = v }
        opts.on("-j", "--json")    { |v| options[:json]    = v }
        opts.on(      "--trace")   { |v| options[:trace]   = v }
        opts.on("-d", "--debug")   { |v| Facter.debugging(1) }
        opts.on("-t", "--timing")  { |v| Facter.timing(1) }
        opts.on("-p", "--puppet")  { |v| load_puppet }
        opts.on("-n", "--nocolor") { |v| Facter.color(0) }

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

    # This provides a wrapper around pretty_output which outputs the top level
    # keys as puppet-style variables. For example:
    #
    #     $key1 = value
    #     $key2 = [
    #       'value1',
    #       'value2',
    #     ]
    #
    def self.facter_output(data)
      t = Facter::Util::Text.new

      # Line up equals signs
      size_ordered = data.keys.sort_by {|x| x.length}
      max_var_length = size_ordered[-1].length

      data.sort.each do |e|
        k,v = e
        $stdout.write("#{t.yellow}$#{k}#{t.reset}")
        indent(max_var_length - k.length, " ")
        $stdout.write(" = ")
        pretty_output(v)
      end
    end

    # This method returns formatted output (with color where applicable) from
    # basic types (hashes, arrays, strings, booleans and numbers).
    def self.pretty_output(data, indent = 0)
      t = Facter::Util::Text.new

      case data
      when Hash
        puts "#{t.magenta}{#{t.reset}"
        indent = indent+1
        data.sort.each do |e|
          k,v = e
          indent(indent)
          $stdout.write "#{t.green}\"#{k}\"#{t.reset} => "
          case v
          when String,TrueClass,FalseClass
            pretty_output(v, indent)
          when Hash,Array
            pretty_output(v, indent)
          end
        end
        indent(indent-1)
        puts "#{t.magenta}}#{t.reset}#{tc(indent-1)}"
      when Array
        puts "#{t.magenta}[#{t.reset}"
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
        puts "#{t.magenta}]#{t.reset}#{tc(indent-1)}"
      when TrueClass,FalseClass,Numeric
        puts "#{t.cyan}#{data}#{t.reset}#{tc(indent)}"
      when String
        puts "#{t.green}\"#{data}\"#{t.reset}#{tc(indent)}"
      end
    end

    # Provide a trailing comma if required
    def self.tc(indent)
      indent > 0 ? "," : ""
    end

    # Return a series of space characters based on a provided indent size and
    # the number of indents required.
    def self.indent(num, indent = "  ")
      num.times { $stdout.write(indent) }
    end

  end
end

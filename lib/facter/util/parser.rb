require 'facter/util/cache'

# This class acts as the factory and parent class for parsed
# facts such as scripts, text, json and yaml files.
#
# Parsers must subclass this class and provide their own #results method.
class Facter::Util::Parser
  # filename to parse
  attr_reader :filename

  # Facter::Util::Cache object
  attr_accessor :cache
  
  class << self
    # Retrieve the set extension, if any
    attr_reader :extension
  end

  # Used by subclasses. Registers +ext+ as the extension to match.
  def self.matches_extension(ext)
    @extension = ext
  end

  # Returns file extension from the given +filename+.
  def self.file_extension(filename)
    File.extname(filename).sub(".", '')
  end

  # When inherited this method is called to register subclasses.
  def self.inherited(klass)
    @subclasses ||= []
    @subclasses << klass
  end

  # Used by subclasses. Returns +true+ if it matches +filename+.
  #
  # Subclasses can override this method to customize the behaviour.
  def self.matches?(filename)
    raise "Must override the 'matches?' method for #{self}" unless extension

    file_extension(filename) == extension
  end

  # Return the list of subclasses.
  def self.subclasses
    @subclasses ||= []
    @subclasses
  end

  # Analyse all subclasses to see which one is the best match for handling
  # the file.
  def self.which_parser(filename)
    unless klass = subclasses.detect {|k| k.matches?(filename) }
      Facter.warn "Could not find parser for #{filename}"
      return nil
    end
    klass
  end

  # Return a new parser object that can handle +filename+.
  def self.new(filename, cache = nil)
    klass = which_parser(filename)

    if klass == nil
      return nil
    end
    
    object = klass.allocate
    object.send(:initialize, filename)

    if cache
      object.cache = cache
    end

    object
  end
  
  # Initialize parser subclass.
  def initialize(filename)
    @filename = filename
  end

  # Parses static files containing #YAML content.
  class YamlParser < self
    matches_extension "yaml"

    # Returns a hash of text from #YAML content.
    def results
      require 'yaml'

      yaml_data = YAML.load_file(filename)

      yaml_data ? yaml_data : nil
    rescue Exception => e
      Facter.warn("Failed to handle #{filename} as yaml facts: #{e.class}: #{e}")
    end
  end

  # Parses static text files with key value pairs.
  class TextParser < self
    matches_extension "txt"

    # Returns a hash of facts from text content.
    def results
      result = nil
      File.readlines(filename).each do |line|
        result ||= {}
        if line.chomp =~ /^(.+)=(.+)$/
          result[$1.strip] = $2.strip
        end
      end
      result
    rescue Exception => e
      Facter.warn("Failed to handle #{filename} as text facts: #{e.class}: #{e}")
    end
  end

  # Parses static files containing #JSON content.
  class JsonParser < self
    matches_extension "json"
    
    # Returns a hash of facts from #JSON content.
    def results
      attempts = 0
      begin
        require 'json'
      rescue LoadError => e
        raise e if attempts >= 1
        attempts += 1
        require 'rubygems'
        retry
      end

      JSON.load(File.read(filename))
    rescue Exception => e
      Facter.warn("Failed to handle #{filename} as json facts: #{e.class}: #{e}")
    end
  end

  # Executes and parses the key value output of executable files.
  class ScriptParser < self
    if Facter::Util::Config.is_windows?
      matches_extension "bat"
    else
      # Returns true if file is executable.
      def self.matches?(file)
        File.executable?(file)
      end
    end

    # Returns a hash of facts from script output.
    def results
      if cache and result = cache[filename]
        Facter.debug("Using cached data for #{filename}")
        return result
      end

      output = Facter::Util::Resolution.exec(filename)

      result = nil
      output.split("\n").each do |line|
        if line =~ /^(.+)=(.+)$/
          result ||= {}
          result[$1.strip] = $2.strip
        end
      end

      if cache and cache.ttl(filename) > 0
        Facter.debug("Updating cache for #{filename}")
        cache[filename] = result
      end

      result
    rescue Exception => e
      Facter.warn("Failed to handle #{filename} as script facts: #{e.class}: #{e}")
      Facter.debug(e.backtrace.join("\n\t"))
    end
  end
end

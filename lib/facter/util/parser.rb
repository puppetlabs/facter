require 'facter/util/cache'

class Facter::Util::Parser
  attr_reader :filename
  attr_accessor :cache
  
  class << self
    # Retrieve the set extension, if any
    attr_reader :extension
  end

  # Register the extension that this parser matches.
  def self.matches_extension(ext)
    @extension = ext
  end

  def self.file_extension(filename)
    File.extname(filename).sub(".", '')
  end

  def self.inherited(klass)
    @subclasses ||= []
    @subclasses << klass
  end

  def self.matches?(filename)
    raise "Must override the 'matches?' method for #{self}" unless extension

    file_extension(filename) == extension
  end

  def self.subclasses
    @subclasses ||= []
    @subclasses
  end

  def self.which_parser(filename)
    unless klass = subclasses.detect {|k| k.matches?(filename) }
      raise ArgumentError, "Could not find parser for #{filename}"
    end
    klass
  end

  def self.new(filename, cache = nil)
    klass = which_parser(filename)
    
    object = klass.allocate
    object.send(:initialize, filename)

    if cache
      object.cache = cache
    end

    object
  end
  
  def initialize(filename)
    @filename = filename
  end

  class YamlParser < self
    matches_extension "yaml"

    def results
      require 'yaml'

      YAML.load_file(filename)
    rescue Exception => e
      Facter.warn("Failed to handle #{filename} as yaml facts: #{e.class}: #{e}")
    end
  end

  class TextParser < self
    matches_extension "txt"

    def results
      result = {}
      File.readlines(filename).each do |line|

        if line.chomp =~ /^(.+)=(.+)$/
          result[$1] = $2
        end
      end
      result
    rescue Exception => e
      Facter.warn("Failed to handle #{filename} as text facts: #{e.class}: #{e}")
    end
  end

  class JsonParser < self
    matches_extension "json"
    
    def results
      begin
        require 'json'
      rescue LoadError
        require 'rubygems'
        retry
      end

      JSON.load(File.read(filename))
    end
  end

  class ScriptParser < self
    def self.matches?(file)
      File.executable?(file)
    end

    def results
      if cache and result = cache[filename]
        Facter.debug("Using cached data for #{filename}")
        return result
      end

      output = Facter::Util::Resolution.exec(filename)

      result = {}
      output.split("\n").each do |line|
        if line =~ /^(.+)=(.+)$/
          result[$1] = $2
        end
      end

      if cache and ttl > 0
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

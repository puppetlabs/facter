require 'facter/util/cache'

# This class acts as the factory and parent class for parsed
# facts such as scripts, text, json and yaml files.
#
# Parsers must subclass this class and provide their own #results method.
class Facter::Util::Parser
  # filename to parse
  attr_reader :filename

  class << self
    # Retrieve the set extension, if any
    attr_reader :extension
  end

  # Used by subclasses. Registers +ext+ as the extension to match.
  #
  # For support mutliple extensions you can pass an array of extensions as
  # +ext+.
  def self.matches_extension(ext)
    if ext.class == String then
      @extension = ext.downcase
    elsif ext.class == Array then
      @extension = ext.collect {|x| x.downcase }
    end
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

    [extension].flatten.to_a.include?(file_extension(filename).downcase)
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
  def self.new(filename)
    klass = which_parser(filename)

    if klass == nil
      return nil
    end
    
    object = klass.allocate
    object.send(:initialize, filename)

    object
  end

  def ttl
    meta = filename + ".ttl"

    return 0 unless File.exist?(meta)
    return File.read(meta).chomp.to_i
  end
  
  # Initialize parser subclass.
  def initialize(filename)
    @filename = filename
  end

  # Return results and report timing and handle cache.
  def values
    starttime = Time.now.to_f

    from_cache = false
    result = begin
      Facter::Util::Cache.get(filename,ttl)
    rescue Exception => e
      :noentry
    end

    if result != :noentry
      # Use cache results if they exist
      Facter.debug("Using cached data for #{filename}")
      return_values = result
      from_cache = true
    else
      # Run external fact and optionally cache results
      return_values = results

      if return_values
        Facter.debug("Updating cache for #{filename}")
        Facter::Util::Cache.set(filename,return_values,ttl)
      end
    end

    finishtime = Time.now.to_f
    ms = (finishtime - starttime) * 1000
    timing_output = "#{filename}: #{"%.2f" % ms}ms"
    timing_output += " (cached)" if from_cache
    Facter.show_time timing_output

    return_values
  end

  # This method must be overwriten by subclasses to provide
  # the results (as a hash) of parsing the filename.
  def results
    raise "Must override the 'results' method for #{self}"   
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
      matches_extension %w{bat com exe}
    else
      # Returns true if file is executable.
      def self.matches?(file)
        File.executable?(file)
      end
    end

    # Returns a hash of facts from script output.
    def results
      output = Facter::Util::Resolution.exec(filename)

      result = nil
      output.split("\n").each do |line|
        if line =~ /^(.+)=(.+)$/
          result ||= {}
          result[$1.strip] = $2.strip
        end
      end

      result
    rescue Exception => e
      Facter.warn("Failed to handle #{filename} as script facts: #{e.class}: #{e}")
      Facter.debug(e.backtrace.join("\n\t"))
    end
  end

  # Executes and parses the key value output of Powershell scripts
  # 
  # Before you can run unsigned ps1 scripts it requires a change to execution 
  # policy:
  #
  #   Set-ExecutionPolicy RemoteSigned -Scope LocalMachine
  #   Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
  #
  class PowershellParser < self
    matches_extension "ps1"

    # Only return true if this is a windows box
    def self.matches?(filename)
      if Facter::Util::Config.is_windows?
        super(filename)
      else
        return false
      end
    end

    # Returns a hash of facts from powershell output
    def results
      shell_command = 'powershell -File "' + filename + '"'
      output = Facter::Util::Resolution.exec(shell_command)

      result = nil
      output.split("\n").each do |line|
        if line =~ /^(.+)=(.+)$/
          result ||= {}
          result[$1.strip] = $2.strip
        end
      end

      result
    rescue Exception => e
      Facter.warn("Failed to handle #{filename} as powershell facts: #{e.class}: #{e}")
      Facter.debug(e.backtrace.join("\n\t"))
    end
  end

end

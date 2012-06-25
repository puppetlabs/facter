# This class acts as the factory and parent class for parsed
# facts such as scripts, text, json and yaml files.
#
# Parsers must subclass this class and provide their own #results method.
require 'facter/util/json'

module Facter::Util::Parser
  @parsers = []
  
  # For support mutliple extensions you can pass an array of extensions as
  # +ext+.
  def self.extension_matches?(filename, ext)
    if ext.class == String then
      extension = ext.downcase
    elsif ext.class == Array then
      extension = ext.collect {|x| x.downcase }
    end
    [extension].flatten.to_a.include?(file_extension(filename).downcase)
  end
    
  def self.file_extension(filename)
    File.extname(filename).sub(".", '')
  end
  
  def self.register(klass, &suitable)
    @parsers << [klass, suitable]
  end

  def self.parser_for(filename)
    registration = @parsers.detect { |k| k[1].call(filename) }
    
    if registration.nil?
      NothingParser.new
    else
      registration[0].new(filename)
    end
  end

  class Base
    attr_reader :filename
    
    def initialize(filename)
      @filename = filename
    end
  end

  class YamlParser < Base
    def results
      require 'yaml'

      YAML.load_file(filename)
    rescue Exception => e
      Facter.warn("Failed to handle #{filename} as yaml facts: #{e.class}: #{e}")
    end
  end
  
  register(YamlParser) do |filename|
    extension_matches?(filename, "yaml")
  end

  class TextParser < Base
    def self.matches?(filename)
      extension_matches?(filename, "txt")
    end

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
  
  register(TextParser) do |filename|
    extension_matches?(filename, "txt")
  end

  if Facter.json?
    class JsonParser < Base
      def self.matches?(filename)
        extension_matches?(filename, "json")
      end

      def results
        attempts = 0
        begin
          require 'json'
        rescue LoadError => e
          raise e if attempts >= 1
          attempts += 1
        end

        JSON.load(File.read(filename))
      end
    end
    
    register(JsonParser) do |filename|
      extension_matches?(filename, "json")
    end
  end

  class ScriptParser < Base
    def results
      output = Facter::Util::Resolution.exec(filename)

      result = {}
      output.split("\n").each do |line|
        if line =~ /^(.+)=(.+)$/
          result[$1] = $2
        end
      end

      result
    rescue Exception => e
      Facter.warn("Failed to handle #{filename} as script facts: #{e.class}: #{e}")
      Facter.debug(e.backtrace.join("\n\t"))
    end
  end

  register(ScriptParser) do |filename|
    if Facter::Util::Config.is_windows?
      extension_matches?(filename, %w{bat com exe})
    else
      File.executable?(filename)
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
  class PowershellParser < Base
    # Returns a hash of facts from powershell output
    def results
      shell_command = "powershell -File #{filename}"
      output = Facter::Util::Resolution.exec(shell_command)

      result = {}
      output.split("\n").each do |line|
        if line =~ /^(.+)=(.+)$/
          result[$1] = $2
        end
      end

      result
    rescue Exception => e
      Facter.warn("Failed to handle #{filename} as powershell facts: #{e.class}: #{e}")
      Facter.debug(e.backtrace.join("\n\t"))
    end
  end

  register(PowershellParser) do |filename|
    Facter::Util::Config.is_windows? && extension_matches?(filename, "ps1")
  end
  
  # A parser that is used when there is no other parser that can handle the file
  # The return from results indicates to the caller the file was not parsed correctly.
  class NothingParser
    def results
      false
    end
  end
end

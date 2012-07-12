# This class acts as the factory and parent class for parsed
# facts such as scripts, text, json and yaml files.
#
# Parsers must subclass this class and provide their own #results method.
require 'facter'

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

  class JsonParser < Base
    def self.matches?(filename)
      extension_matches?(filename, "json")
    end

    def results
      if Facter.json?
        JSON.load(File.read(filename))
      else
        Facter.warnonce "Cannot parse JSON data file #{filename} without the json library."
        Facter.warnonce "Suggested next step is `gem install json` to install the json library."
        nil
      end
    end
  end

  register(JsonParser) do |filename|
    extension_matches?(filename, "json")
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
    File.executable?(filename) && File.file?(filename)
  end


  # A parser that is used when there is no other parser that can handle the file
  # The return from results indicates to the caller the file was not parsed correctly.
  class NothingParser
    def results
      false
    end
  end
end

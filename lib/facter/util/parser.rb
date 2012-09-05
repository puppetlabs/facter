# This class acts as the factory and parent class for parsed
# facts such as scripts, text, json and yaml files.
#
# Parsers must subclass this class and provide their own #results method.
require 'facter'
require 'yaml'

module Facter::Util::Parser
  @parsers = []

  # For support mutliple extensions you can pass an array of extensions as
  # +ext+.
  def self.extension_matches?(filename, ext)
    extension = case ext
    when String
      ext.downcase
    when Enumerable
      ext.collect {|x| x.downcase }
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

    def initialize(filename, content = nil)
      @filename = filename
      @content  = content
    end

    def content
      @content ||= File.read(filename)
    end

    # results on the base class is really meant to be just an exception handler
    # wrapper.
    def results
      parse_results
    rescue Exception => detail
      Facter.warn("Failed to handle #{filename} as #{self.class} facts")
      Facter.warn("detail: #{detail.class}: #{detail.message}")
      Facter.debug(detail.backtrace.join("\n\t"))
      nil
    end

    def parse_results
      raise ArgumentError, "Subclasses must respond to parse_results"
    end
  end

  class YamlParser < Base
    def parse_results
      YAML.load(content)
    end
  end

  register(YamlParser) do |filename|
    extension_matches?(filename, "yaml")
  end

  class TextParser < Base
    def parse_results
      re = /^(.+?)=(.+)$/
      result = {}
      content.each_line do |line|
        if match_data = re.match(line.chomp)
          result[match_data[1]] = match_data[2]
        end
      end
      result
    end
  end

  register(TextParser) do |filename|
    extension_matches?(filename, "txt")
  end

  class JsonParser < Base
    def results
      if Facter.json?
        JSON.load(content)
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
      re = /^(.+)=(.+)$/
      output.each_line do |line|
        if match_data = re.match(line.chomp)
          result[match_data[1]] = match_data[2]
        end
      end
      result
    end
  end

  register(ScriptParser) do |filename|
    if not Facter::Util::Config.is_windows?
      File.executable?(filename) && File.file?(filename)
    end
  end


  # A parser that is used when there is no other parser that can handle the file
  # The return from results indicates to the caller the file was not parsed correctly.
  class NothingParser
    def results
      nil
    end
  end
end

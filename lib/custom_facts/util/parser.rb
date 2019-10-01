# frozen_string_literal: true

# This class acts as the factory and parent class for parsed
# facts such as scripts, text, json and yaml files.
#
# Parsers must subclass this class and provide their own #results method.
require 'yaml'

module LegacyFacter
  module Util
    module Parser
      @parsers = []

      # For support mutliple extensions you can pass an array of extensions as
      # +ext+.
      def self.extension_matches?(filename, ext)
        extension = case ext
                    when String
                      ext.downcase
                    when Enumerable
                      ext.collect(&:downcase)
                    end
        [extension].flatten.to_a.include?(file_extension(filename).downcase)
      end

      def self.file_extension(filename)
        File.extname(filename).sub('.', '')
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
        rescue Exception => e
          LegacyFacter.log_exception(e, "Failed to handle #{filename} as #{self.class} facts: #{e.message}")
          nil
        end

        def parse_results
          raise ArgumentError, 'Subclasses must respond to parse_results'
        end
      end

      module KeyValuePairOutputFormat
        def self.parse(output)
          return {} if output.nil?

          result = {}
          re = /^(.+?)=(.+)$/
          output.each_line do |line|
            if (match_data = re.match(line.chomp))
              result[match_data[1]] = match_data[2]
            end
          end
          result
        end
      end

      class YamlParser < Base
        def parse_results
          YAML.safe_load(content)
        end
      end

      register(YamlParser) do |filename|
        extension_matches?(filename, 'yaml')
      end

      class TextParser < Base
        def parse_results
          KeyValuePairOutputFormat.parse content
        end
      end

      register(TextParser) do |filename|
        extension_matches?(filename, 'txt')
      end

      class JsonParser < Base
        def parse_results
          if LegacyFacter.json?
            JSON.parse(content)
          else
            LegacyFacter.warnonce "Cannot parse JSON data file #{filename} without the json library."
            LegacyFacter.warnonce 'Suggested next step is `gem install json` to install the json library.'
            nil
          end
        end
      end

      register(JsonParser) do |filename|
        extension_matches?(filename, 'json')
      end

      class ScriptParser < Base
        def parse_results
          KeyValuePairOutputFormat.parse LegacyFacter::Core::Execution.exec(quote(filename))
        end

        private

        def quote(filename)
          filename.index(' ') ? "\"#{filename}\"" : filename
        end
      end

      register(ScriptParser) do |filename|
        if LegacyFacter::Util::Config.windows?
          extension_matches?(filename, %w[bat cmd com exe]) && File.file?(filename)
        else
          File.executable?(filename) && File.file?(filename) && !extension_matches?(filename, %w[bat cmd com exe])
        end
      end

      # Executes and parses the key value output of Powershell scripts
      class PowershellParser < Base
        # Returns a hash of facts from powershell output
        def parse_results
          powershell =
            if File.exist?("#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe")
              "#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe"
            elsif File.exist?("#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe")
              "#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe"
            else
              'powershell.exe'
            end

          shell_command =
            "\"#{powershell}\" -NoProfile -NonInteractive -NoLogo -ExecutionPolicy Bypass -File \"#{filename}\""
          output = LegacyFacter::Core::Execution.exec(shell_command)
          KeyValuePairOutputFormat.parse(output)
        end
      end

      register(PowershellParser) do |filename|
        LegacyFacter::Util::Config.windows? && extension_matches?(filename, 'ps1') && File.file?(filename)
      end

      # A parser that is used when there is no other parser that can handle the file
      # The return from results indicates to the caller the file was not parsed correctly.
      class NothingParser
        def results
          nil
        end
      end
    end
  end
end

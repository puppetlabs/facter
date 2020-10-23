# frozen_string_literal: true

# This class acts as the factory and parent class for parsed
# facts such as scripts, text, json and yaml files.
#
# Parsers must subclass this class and provide their own #results method.

module LegacyFacter
  module Util
    module Parser
      STDERR_MESSAGE = 'Command %s completed with the following stderr message: %s'

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
          @content ||= Facter::Util::FileHelper.safe_read(filename, nil)
        end

        # results on the base class is really meant to be just an exception handler
        # wrapper.
        def results
          parse_results
        rescue StandardError => e
          Facter.log_exception(e, "Failed to handle #{filename} as #{self.class} facts: #{e.message}")
          nil
        end

        def parse_results
          raise ArgumentError, 'Subclasses must respond to parse_results'
        end

        def parse_executable_output(output)
          res = nil
          begin
            res = YAML.safe_load(output, [Symbol, Time])
          rescue StandardError => e
            Facter.debug("Could not parse executable fact output as YAML or JSON (#{e.message})")
          end
          res = KeyValuePairOutputFormat.parse output unless res.is_a?(Hash)
          res
        end

        def log_stderr(msg, command, file)
          return if !msg || msg.empty?

          file_name = file.split('/').last
          logger = Facter::Log.new(file_name)

          logger.warn(format(STDERR_MESSAGE, command, msg.strip))
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

      # This regex was taken from Psych and adapted
      # https://github.com/ruby/psych/blob/d2deaa9adfc88fc0b870df022a434d6431277d08/lib/psych/scalar_scanner.rb#L9
      # It is used to detect Time in YAML, but we use it to wrap time objects in quotes to be treated as strings.
      TIME =
        /(\d{4}-\d{1,2}-\d{1,2}(?:[Tt]|\s+)\d{1,2}:\d\d:\d\d(?:\.\d*)?(?:\s*(?:Z|[-+]\d{1,2}:?(?:\d\d)?))?\s*$)/.freeze

      class YamlParser < Base
        def parse_results
          # Add quotes to Yaml time
          cont = content.gsub(TIME, '"\1"')

          YAML.safe_load(cont, [Date])
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
          stdout, stderr = Facter::Core::Execution.execute_command(quote(filename), nil)
          log_stderr(stderr, filename, filename)
          parse_executable_output(stdout)
        end

        private

        def quote(filename)
          filename.index(' ') ? "\"#{filename}\"" : filename
        end
      end

      register(ScriptParser) do |filename|
        if LegacyFacter::Util::Config.windows?
          extension_matches?(filename, %w[bat cmd com exe]) && FileTest.file?(filename)
        else
          File.executable?(filename) && FileTest.file?(filename) && !extension_matches?(filename, %w[bat cmd com exe])
        end
      end

      # Executes and parses the key value output of Powershell scripts
      class PowershellParser < Base
        # Returns a hash of facts from powershell output
        def parse_results
          powershell =
            if File.readable?("#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe")
              "#{ENV['SYSTEMROOT']}\\sysnative\\WindowsPowershell\\v1.0\\powershell.exe"
            elsif File.readable?("#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe")
              "#{ENV['SYSTEMROOT']}\\system32\\WindowsPowershell\\v1.0\\powershell.exe"
            else
              'powershell.exe'
            end

          shell_command =
            "\"#{powershell}\" -NoProfile -NonInteractive -NoLogo -ExecutionPolicy Bypass -File \"#{filename}\""
          stdout, stderr = Facter::Core::Execution.execute_command(shell_command)
          log_stderr(stderr, shell_command, filename)
          parse_executable_output(stdout)
        end
      end

      register(PowershellParser) do |filename|
        LegacyFacter::Util::Config.windows? && extension_matches?(filename, 'ps1') && FileTest.file?(filename)
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

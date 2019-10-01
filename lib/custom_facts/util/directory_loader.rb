# frozen_string_literal: true

# A Facter plugin that loads external facts.
#
# Default Unix Directories:
# /opt/puppetlabs/custom_facts/facts.d, /etc/custom_facts/facts.d, /etc/puppetlabs/custom_facts/facts.d
#
# Beginning with Facter 3, only /opt/puppetlabs/custom_facts/facts.d will be a default external fact
# directory in Unix.
#
# Default Windows Direcotires:
# C:\ProgramData\Puppetlabs\custom_facts\facts.d (2008)
# C:\Documents and Settings\All Users\Application Data\Puppetlabs\custom_facts\facts.d (2003)
#
# Can also load from command-line specified directory
#
# Facts can be in the form of JSON, YAML or Text files
# and any executable that returns key=value pairs.

require 'yaml'

module LegacyFacter
  module Util
    class DirectoryLoader
      class NoSuchDirectoryError < RuntimeError
      end

      # This value makes it highly likely that external facts will take
      # precedence over all other facts
      EXTERNAL_FACT_WEIGHT = 10_000

      # Directory for fact loading
      attr_reader :directory

      def initialize(dir, weight = nil)
        @directory = dir
        @weight = weight || EXTERNAL_FACT_WEIGHT
      end

      def self.loader_for(dir)
        raise NoSuchDirectoryError unless File.directory?(dir)

        LegacyFacter::Util::DirectoryLoader.new(dir)
      end

      def self.default_loader
        loaders = LegacyFacter::Util::Config.external_facts_dirs.collect do |dir|
          LegacyFacter::Util::DirectoryLoader.new(dir)
        end
        LegacyFacter::Util::CompositeLoader.new(loaders)
      end

      # Load facts from files in fact directory using the relevant parser classes to
      # parse them.
      def load(collection)
        weight = @weight
        entries.each do |file|
          parser = LegacyFacter::Util::Parser.parser_for(file)
          next if parser.nil?

          data = parser.results
          if data == false
            LegacyFacter.warn "Could not interpret fact file #{file}"
          elsif (data == {}) || data.nil?
            LegacyFacter.warn "Fact file #{file} was parsed but returned an empty data set"
          else
            data.each { |p, v| collection.add(p, value: v) { has_weight(weight) } }
          end
        end
      end

      private

      def entries
        Dir.entries(directory).find_all { |f| should_parse?(f) }.sort.map { |f| File.join(directory, f) }
      rescue Errno::ENOENT
        []
      end

      def should_parse?(file)
        file !~ /^\./
      end
    end
  end
end

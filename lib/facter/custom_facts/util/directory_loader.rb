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
      attr_reader :directories

      def initialize(dir = LegacyFacter::Util::Config.external_facts_dirs, weight = EXTERNAL_FACT_WEIGHT)
        @directories = [dir].flatten
        @weight = weight
        @log ||= Facter::Log.new(self)
      end

      # Load facts from files in fact directory using the relevant parser classes to
      # parse them.
      def load(collection)
        weight = @weight

        searched_facts, cached_facts = load_directory_entries

        load_cached_facts(collection, cached_facts, weight)

        load_searched_facts(collection, searched_facts, weight)
      end

      private

      def load_directory_entries
        cache_manager = Facter::CacheManager.new
        cache_manager.resolve_facts(
          resolve_unstructured_facts(unstructured_entries, cache_manager) +
          resolve_structured_facts(structured_entries, cache_manager)
        )
      end

      def build_searched_fact(basename, file, structured)
        fact_attributes = Facter::FactAttributes.new(
          user_query: nil,
          filter_tokens: [],
          structured: structured,
          file: file
        )
        Facter::SearchedFact.new(basename, nil, :file, fact_attributes)
      end

      def resolve_structured_facts(fact_list, cache_manager)
        resolve_facts(fact_list, cache_manager, true)
      end

      def resolve_unstructured_facts(fact_list, cache_manager)
        resolve_facts(fact_list, cache_manager, false)
      end

      def resolve_facts(fact_list, cache_manager, structured)
        facts = []
        fact_list.each do |file|
          basename = File.basename(file)

          next if file_blocked?(basename)

          if facts.find { |f| f.name == basename } && cache_manager.fact_cache_enabled?(basename)
            Facter.log_exception(Exception.new("Caching is enabled for group \"#{basename}\" while "\
              'there are at least two external facts files with the same filename'))
          else
            facts << build_searched_fact(basename, file, structured)
          end
        end
        facts
      end

      def load_cached_facts(collection, cached_facts, weight)
        cached_facts.each do |cached_fact|
          collection.add(cached_fact.name,
                         value: cached_fact.value,
                         fact_type: :external, file: cached_fact.file,
                         structured: cached_fact.structured) { has_weight(weight) }
        end
      end

      def load_searched_facts(collection, searched_facts, weight)
        searched_facts.each do |fact|
          parser = LegacyFacter::Util::Parser.parser_for(fact.file)
          next if parser.nil?

          data = resolve_fact(fact, parser)

          if data == false
            LegacyFacter.warn "Could not interpret fact file #{fact.file}"
          elsif (data == {}) || data.nil?
            @log.debug("Fact file #{fact.file} was parsed but no key=>value data was returned")
          else
            data.each do |p, v|
              collection.add(p, value: v, fact_type: :external,
                                file: fact.file, structured: fact.structured) { has_weight(weight) }
            end
          end
        end
      end

      def resolve_fact(fact, parser)
        data = nil
        fact_name = File.basename(fact.file)
        Facter::Framework::Benchmarking::Timer.measure(fact_name) { data = parser.results }

        data
      end

      def unstructured_entries
        dirs = @directories.select { |directory| File.directory?(directory) }.map do |directory|
          Dir.entries(directory).map { |directory_entry| File.join(directory, directory_entry) }.sort.reverse!
        end
        dirs.flatten.select { |f| should_parse?(f) }
      rescue Errno::ENOENT
        []
      end

      def structured_entries
        dirs = @directories.select { |directory| File.directory?(directory) }.map do |directory|
          structured_dir = File.join(directory, 'structured')
          next unless File.directory?(structured_dir)

          Dir.entries(structured_dir).map do |directory_entry|
            File.join(structured_dir, directory_entry)
          end
        end

        dirs.flatten.compact.select { |f| should_parse?(f) }
      rescue Errno::ENOENT
        []
      end

      def should_parse?(file)
        File.file?(file) && File.basename(file) !~ /^\./
      end

      def file_blocked?(file)
        if Facter::Options[:blocked_facts].include? file
          Facter.debug("External fact file #{file} blocked.")
          return true
        end
        false
      end
    end
  end
end

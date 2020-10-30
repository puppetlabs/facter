
module Facter
  module Cache
    class CacheWriter

      def initialize
        @log = Log.new(self)
        @groups = {}
        @fact_groups = Facter::FactGroups.new
        @cache_dir = LegacyFacter::Util::Config.facts_cache_dir
      end

      def cache_facts(resolved_facts)
        return unless Options[:cache] && Options[:ttls].any?

        resolved_facts
          .select { |resolved_fact| resolved_fact.cache_group != nil }
          .group_by { |resolved_fact| resolved_fact.cache_group }
          .each do |group_name, array_of_facts|
          @groups[group_name] ||= {}
          array_of_facts.each { |resolved_fact| @groups[group_name][resolved_fact.name] = resolved_fact.value}
        end

        begin
          write_cache unless @groups.empty?
        rescue Errno::EACCES => e
          @log.warn("Could not write cache: #{e.message}")
        end
      end

      private

      def write_cache
        unless File.directory?(@cache_dir)
          require 'fileutils'
          FileUtils.mkdir_p(@cache_dir)
        end

        @groups.each do |group_name, data|
          next unless check_ttls?(group_name, @fact_groups.get_group_ttls(group_name))

          cache_file_name = File.join(@cache_dir, group_name)
          next if File.readable?(cache_file_name)

          @log.debug("caching values for #{group_name} facts")
          File.write(cache_file_name, JSON.pretty_generate(data))
        end
      end

      def check_ttls?(group_name, ttls)
        return false unless ttls

        cache_file_name = File.join(@cache_dir, group_name)
        if File.readable?(cache_file_name)
          file_time = File.mtime(cache_file_name)
          expire_date = file_time + ttls
          return true if expire_date > Time.now

          File.delete(cache_file_name)
        end

        @log.debug("#{group_name} facts cache file expired/missing")
        true
      end
    end
  end
end


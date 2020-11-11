# frozen_string_literal: true

module Facter
  class CacheManager
    def initialize
      @groups = {}
      @log = Log.new(self)
      @fact_groups = Facter::FactGroups.new
      @cache_dir = LegacyFacter::Util::Config.facts_cache_dir
    end

    def resolve_facts(searched_facts)
      return searched_facts, [] if (!File.directory?(@cache_dir) || !Options[:cache]) && Options[:ttls].any?

      facts = []
      searched_facts.delete_if do |fact|
        res = resolve_fact(fact)
        if res
          facts << res
          true
        else
          false
        end
      end

      [searched_facts, facts.flatten]
    end

    def cache_facts(resolved_facts)
      return unless Options[:cache] && Options[:ttls].any?

      @groups = {}
      resolved_facts.each do |fact|
        cache_fact(fact)
      end

      begin
        write_cache unless @groups.empty?
      rescue Errno::EACCES => e
        @log.warn("Could not write cache: #{e.message}")
      end
    end

    def fact_cache_enabled?(fact_name)
      fact = @fact_groups.get_fact(fact_name)
      cached = if fact
                 !fact[:ttls].nil?
               else
                 false
               end

      fact_group = @fact_groups.get_fact_group(fact_name)
      delete_cache(fact_group) if fact_group && !cached
      cached
    end

    private

    def resolve_fact(searched_fact)
      fact_name = if searched_fact.file
                    File.basename(searched_fact.file)
                  else
                    searched_fact.name
                  end

      return unless fact_cache_enabled?(fact_name)

      fact = @fact_groups.get_fact(fact_name)

      return if external_fact_in_custom_group?(searched_fact, fact_name, fact)

      return unless fact

      return unless check_ttls?(fact[:group], fact[:ttls])

      read_fact(searched_fact, fact[:group])
    end

    def external_fact_in_custom_group?(searched_fact, fact_name, fact)
      if searched_fact.file && fact[:group] != fact_name
        @log.error("Can not cache #{fact_name} fact from #{fact[:group]} group."\
                    'Cache group is not supported for external facts')
        return true
      end

      false
    end

    def read_fact(searched_fact, fact_group)
      data = nil
      Facter::Framework::Benchmarking::Timer.measure(searched_fact.name, 'cached') do
        data = read_group_json(fact_group)
      end
      return unless data

      unless searched_fact.file
        return unless valid_format_version?(searched_fact, data, fact_group)

        data.fetch(searched_fact.name) { delete_cache(fact_group) }
      end

      @log.debug("loading cached values for #{searched_fact.name} facts")

      create_facts(searched_fact, data)
    end

    def valid_format_version?(searched_fact, data, fact_group)
      unless data['cache_format_version'] == 1
        @log.debug("The fact #{searched_fact.name} could not be read from the cache, \
cache_format_version is incorrect!")
        delete_cache(fact_group)
        return false
      end

      true
    end

    def create_facts(searched_fact, data)
      if searched_fact.type == :file
        resolve_external_fact(searched_fact, data)
      else
        return unless data[searched_fact.name]

        [Facter::ResolvedFact.new(searched_fact.name, data[searched_fact.name], searched_fact.type,
                                  searched_fact.user_query, searched_fact.filter_tokens)]
      end
    end

    def resolve_external_fact(searched_fact, data)
      facts = []
      data.each do |fact_name, fact_value|
        next if fact_name == 'cache_format_version'

        fact = Facter::ResolvedFact.new(fact_name, fact_value, searched_fact.type,
                                        searched_fact.user_query, searched_fact.filter_tokens)
        fact.file = searched_fact.file
        facts << fact
      end
      facts
    end

    def cache_fact(fact)
      fact_name = if fact.file
                    File.basename(fact.file)
                  else
                    fact.name
                  end

      group_name = @fact_groups.get_fact_group(fact_name)

      return unless group_name

      return unless fact_cache_enabled?(fact_name)

      @groups[group_name] ||= {}
      @groups[group_name][fact.name] = fact.value
    end

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

        data['cache_format_version'] = 1
        File.write(cache_file_name, JSON.pretty_generate(data))
      end
    end

    def read_group_json(group_name)
      return @groups[group_name] if @groups.key?(group_name)

      cache_file_name = File.join(@cache_dir, group_name)
      data = nil
      file = Util::FileHelper.safe_read(cache_file_name)
      begin
        data = JSON.parse(file) unless file.nil?
      rescue JSON::ParserError
        delete_cache(group_name)
      end
      @groups[group_name] = data
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

      @log.debug("#{group_name} facts cache file expired, missing or is corrupt")
      true
    end

    def delete_cache(group_name)
      cache_file_name = File.join(@cache_dir, group_name)

      File.delete(cache_file_name) if File.readable?(cache_file_name)
    end
  end
end

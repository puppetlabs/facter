
module Facter
  module Cache
    class CacheReader

      def initialize
        @groups = {}
        @log = Log.new(self)
        @cache_dir = LegacyFacter::Util::Config.facts_cache_dir
      end

      def read_from_cache(searched_facts)
        return searched_facts, [] if (!File.directory?(@cache_dir) || !Options[:cache]) && Options[:ttls].any?

        facts = []
        searched_facts.delete_if do |searched_fact|
          res = read_fact(searched_fact, searched_fact.cache_group) if searched_fact.cache_group
          if res
            facts << res
            true
          else
            false
          end
        end

        [searched_facts, facts.flatten]
      end

      private

      def read_fact(searched_fact, fact_group)
        data = nil
        Facter::Framework::Benchmarking::Timer.measure(searched_fact.name, 'cached') do
          data = read_group_json(fact_group)
        end
        return unless data

        @log.debug("loading cached values for #{searched_fact.name} facts")

        create_facts(searched_fact, data)
      end

      def read_group_json(group_name)
        return @groups[group_name] if @groups.key?(group_name)

        cache_file_name = File.join(@cache_dir, group_name)
        data = nil
        file = Util::FileHelper.safe_read(cache_file_name)
        begin
          data = JSON.parse(file)
        rescue JSON::ParserError
          delete_cache(group_name)
        end
        @groups[group_name] = data
      end

      def delete_cache(group_name)
        cache_file_name = File.join(@cache_dir, group_name)
        File.delete(cache_file_name) if File.readable?(cache_file_name)
      end

      def create_facts(searched_fact, data)
        if searched_fact.type == :file
          facts = []
          data.each do |fact_name, fact_value|
            fact = Facter::ResolvedFact.new(fact_name, fact_value, searched_fact.type,
                                            searched_fact.user_query, searched_fact.filter_tokens, searched_fact.cache_group)
            fact.file = searched_fact.file
            facts << fact
          end
          facts
        else
          [Facter::ResolvedFact.new(searched_fact.name, data[searched_fact.name], searched_fact.type,
                                    searched_fact.user_query, searched_fact.filter_tokens, searched_fact.cache_group)]
        end
      end
    end
  end
end


module Facter
  module Cache
    class CacheAugmenter

      def initialize
        @fact_groups = Facter::FactGroups.new
      end

      def augment_with_cache_group(searched_facts)
        ttls = @fact_groups.facts_ttls

        searched_facts.each do |fact|
          fact_name = if fact.file
                        File.basename(fact.file)
                      else
                        fact.name
                      end

          ttls.each do |fact_key, details|
            fact.cache_group = details[:cache_group] if fact_name =~ /^#{fact_key}[\.]?.*/
          end
        end
      end
    end
  end
end

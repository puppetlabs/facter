module Facter
  class QueryParser
    def self.parse(query, fact_list)
      tokens = query.split('.')
      size = tokens.size
      resolvable_fact_list = []

      size.times do |i|
        elem = 0..size - i

        fact_list.each do |fact_name, klass_name|
          if fact_name.match?(tokens[elem].join('.'))
            filter_tokens = tokens - tokens[elem]

            fact = LoadedFact.new
            fact.filter_tokens = filter_tokens
            fact.fact_class = klass_name
            resolvable_fact_list << fact # [klass_name, filter_tokens]
          end
        end

        return resolvable_fact_list if resolvable_fact_list.any?
      end

      resolvable_fact_list
    end
  end
end

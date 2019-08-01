module Facter
  class OptionParser
    def self.parse(fact_name, fact_list)
      tokens = fact_name.split('.')
      size = tokens.size - 1
      results = []

      size.times do |i|
        elem = 0..size - i

        if fact_list.key?(tokens[elem].join('.'))
          found_fact = fact_list[tokens[elem].join('.')]

          search_tokens = tokens - tokens[elem]

          results << [found_fact, search_tokens]
        end
      end
      results # flatten?
    end
  end
end

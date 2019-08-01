module Facter
  class OptionParser
    def self.parse(fact_name, fact_list)
      tokens = fact_name.split('.')
      size = tokens.size
      results = []

      size.times do |i|
        elem = 0..size - i

        # fact_list.keys.select{|key|}
        fact_list.each do |key, value|
          if key.to_s.match?(tokens[elem].join('.'))
            search_tokens = tokens - tokens[elem]
            results << [value, search_tokens]
          end
        end

        if results.size > 0
          break
        end
      end
      results
    end
  end
end

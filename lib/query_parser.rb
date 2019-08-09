module Facter
  class QueryParser
    # Searches for facts that could resolve a user query.
    # There are 3 types of facts:
    #   root facts
    #     e.g. networking
    #   child facts
    #     e.g. networking.dhcp
    #   composite facts
    #     e.g. networking.interfaces.en0.bindings.address
    # Because a root fact will always be resolved by the collection of child facts,
    # we can return one or more child facts.
    #
    # query -  is the user input used to search for facts
    # fact_list - is a list with all facts for the current operating system
    #
    # Returns a list of LoadedFact objects that resolve the users query.
    # rubocop:disable Metrics/AbcSize
    def self.parse(query, fact_list)
      tokens = query.split('.')
      size = tokens.size
      resolvable_fact_list = []

      size.times do |i|
        elem = 0..size - i

        fact_list.each do |fact_name, klass_name|
          next unless fact_name.match?(tokens[elem].join('.'))
          filter_tokens = tokens - tokens[elem]

          fact = LoadedFact.new
          fact.filter_tokens = filter_tokens
          fact.fact_class = klass_name
          resolvable_fact_list << fact # [klass_name, filter_tokens]
        end

        return resolvable_fact_list if resolvable_fact_list.any?
      end

      resolvable_fact_list
    end
    # rubocop:enable Metrics/AbcSize
  end
end

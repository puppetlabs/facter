# frozen_string_literal: true

module Facter
  class QueryParser
    @log = Log.new(self)
    class << self
      # Searches for facts that could resolve a user query.
      # There are 4 types of facts:
      #   root facts
      #     e.g. networking
      #   child facts
      #     e.g. networking.dhcp
      #   composite facts
      #     e.g. networking.interfaces.en0.bindings.address
      #   regex facts (legacy)
      #     e.g. impaddress_end160
      #
      # Because a root fact will always be resolved by a collection of child facts,
      # we can return one or more child facts for each parent.
      #
      # query -  is the user input used to search for facts
      # loaded_fact - is a list with all facts for the current operating system
      #
      # Returns a list of SearchedFact objects that resolve the users query.
      def parse(query_list, loaded_fact)
        matched_facts = []
        @log.debug "User query is: #{query_list}"
        @query_list = query_list
        query_list = loaded_fact.map(&:name) unless query_list.any?

        query_list.each do |query|
          @log.debug "Query is #{query}"
          found_facts = search_for_facts(query, loaded_fact)
          matched_facts << found_facts
        end

        matched_facts.flatten(1)
      end

      def search_for_facts(query, loaded_fact_hash)
        resolvable_fact_list = []
        query = query.to_s
        query_tokens = query.end_with?('.*') ? [query] : query.split('.')
        size = query_tokens.size

        size.times do |i|
          query_token_range = 0..size - i - 1
          resolvable_fact_list = get_facts_matching_tokens(query_tokens, query_token_range, loaded_fact_hash)

          return resolvable_fact_list if resolvable_fact_list.any?
        end

        resolvable_fact_list
      end

      def get_facts_matching_tokens(query_tokens, query_token_range, loaded_fact_hash)
        @log.debug "Checking query tokens #{query_tokens[query_token_range].join('.')}"
        resolvable_fact_list = []

        loaded_fact_hash.each do |loaded_fact|
          query_fact = query_tokens[query_token_range].join('.')

          next unless found_fact?(loaded_fact.name, query_fact)

          searched_fact = construct_loaded_fact(query_tokens, query_token_range, loaded_fact)
          resolvable_fact_list << searched_fact
        end

        @log.debug "List of resolvable facts: #{resolvable_fact_list.inspect}"
        resolvable_fact_list
      end

      def found_fact?(fact_name, query_fact)
        fact_with_wildcard = fact_name.include?('.*')

        return false if fact_with_wildcard && !query_fact.match("^#{fact_name}$")

        return false unless fact_with_wildcard || fact_name.match("^#{query_fact}($|\\.)")

        true
      end

      def construct_loaded_fact(query_tokens, query_token_range, loaded_fact)
        filter_tokens = construct_filter_tokens(query_tokens, query_token_range)
        user_query = @query_list.any? ? query_tokens.join('.') : ''
        fact_name = loaded_fact.name.to_s
        klass_name = loaded_fact.klass
        type = loaded_fact.type
        SearchedFact.new(fact_name, klass_name, filter_tokens, user_query, type)
      end

      def construct_filter_tokens(query_tokens, query_token_range)
        (query_tokens - query_tokens[query_token_range]).map do |token|
          token =~ /^[0-9]+$/ ? token.to_i : token.to_sym
        end
      end
    end
  end
end

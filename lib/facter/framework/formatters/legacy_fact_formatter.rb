# frozen_string_literal: true

module Facter
  class LegacyFactFormatter
    def initialize
      @log = Log.new(self)
    end

    def format(resolved_facts)
      user_queries = resolved_facts.uniq(&:user_query).map(&:user_query)

      return if user_queries.count < 1
      return format_for_multiple_user_queries(user_queries, resolved_facts) if user_queries.count > 1

      user_query = user_queries.first
      return format_for_no_query(resolved_facts) if user_query.empty?

      format_for_single_user_query(user_queries.first, resolved_facts)
    end

    private

    def format_for_no_query(resolved_facts)
      @log.debug('Formatting for no user query')
      fact_collection = Facter::FormatterHelper.retrieve_fact_collection(resolved_facts)
      pretty_json = hash_to_facter_format(fact_collection)

      pretty_json = remove_enclosing_accolades(pretty_json)
      remove_comma_and_quotation(pretty_json)
    end

    def format_for_multiple_user_queries(user_queries, resolved_facts)
      @log.debug('Formatting for multiple user queries')

      facts_to_display = Facter::FormatterHelper.retrieve_facts_to_display_for_user_query(user_queries, resolved_facts)

      facts_to_display.each { |k, v| facts_to_display[k] = v.nil? ? '' : v }
      pretty_json = hash_to_facter_format(facts_to_display)
      pretty_json = remove_enclosing_accolades(pretty_json)
      pretty_json = remove_comma_and_quotation(pretty_json)

      @log.debug('Remove quotes from value if value is a string')
      pretty_json.gsub(/^(\S*) => \"(.*)\"/, '\1 => \2')
    end

    def format_for_single_user_query(user_query, resolved_facts)
      @log.debug('Formatting for single user query')

      fact_value = Facter::FormatterHelper.retrieve_fact_value_for_single_query(user_query, resolved_facts)

      return fact_value if fact_value.is_a?(String)

      pretty_json = fact_value.nil? ? '' : hash_to_facter_format(fact_value)

      @log.debug('Remove quotes from value if it is a simple string')
      pretty_json.gsub(/^"(.*)\"/, '\1')
    end

    def hash_to_facter_format(facts_hash)
      @log.debug('Converting hash to pretty json')
      pretty_json = JSON.pretty_generate(facts_hash)

      @log.debug('Change key value delimiter from : to =>')
      pretty_json.gsub!(/":\s/, '" => ')

      @log.debug('Remove quotes from parent nodes')
      pretty_json.gsub!(/\"(.*)\"\ =>/, '\1 =>')

      @log.debug('Remove double backslashes from paths')
      pretty_json.gsub(/\\\\/, '\\')
    end

    def remove_enclosing_accolades(pretty_fact_json)
      @log.debug('Removing enclosing accolades')
      pretty_fact_json = pretty_fact_json[1..-2]

      @log.debug('Remove empty lines')
      pretty_fact_json.gsub!(/^$\n/, '')

      @log.debug('Fix indentation after removing enclosed accolades')
      pretty_fact_json = pretty_fact_json.gsub(/^\s\s(.*)$/, '\1')

      @log.debug('remove comas from query results')
      pretty_fact_json.gsub(/^},/, '}')
    end

    def remove_comma_and_quotation(output)
      # quotation marks that come after \ are not removed
      @log.debug('Remove unnecessary comma and quotation marks on root facts')
      output.split("\n")
            .map! { |line| line =~ /^[\s]+/ ? line : line.gsub(/,$|(?<!\\)\"/, '').gsub('\\"', '"') }.join("\n")
    end
  end
end

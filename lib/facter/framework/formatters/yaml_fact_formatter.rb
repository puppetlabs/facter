# frozen_string_literal: true

module Facter
  class YamlFactFormatter
    def initialize
      @log = Log.new(self)
    end

    def format(resolved_facts)
      user_queries = resolved_facts.uniq(&:user_query).map(&:user_query)

      facts_to_display = if user_queries.count == 1 && user_queries.first.empty?
                           FormatterHelper.retrieve_fact_collection(resolved_facts)
                         else
                           FormatterHelper.retrieve_facts_to_display_for_user_query(user_queries, resolved_facts)
                         end

      facts_to_display = Psych.parse_stream(facts_to_display.to_yaml)
      facts_to_display.children[0].tag_directives = []
      yaml_pretty = quote_special_strings(facts_to_display)

      @log.debug('Replace ---  from yaml beginning, to keep it compatible with C facter')
      yaml_pretty.gsub(/^---[\r\n]+/, '')
    end

    private

    def quote_special_strings(fact_hash)
      require 'psych'

      fact_hash.grep(Psych::Nodes::Scalar).each do |node|
        next unless needs_quote?(node.value)

        node.plain  = false
        node.quoted = true
        node.style  = Psych::Nodes::Scalar::DOUBLE_QUOTED
      end

      fact_hash = unquote_keys(fact_hash)
      fact_hash.yaml
    end

    def unquote_keys(fact_hash)
      fact_hash.grep(Psych::Nodes::Mapping).each do |node|
        node.children.each_slice(2) do |k, _|
          k.plain  = true
          k.quoted = false
          k.style  = Psych::Nodes::Scalar::ANY
        end
      end
      fact_hash
    end

    def needs_quote?(value)
      return false if value =~ /true|false/
      return false if value[/^[0-9]+$/]
      return true if value =~ /y|Y|yes|Yes|YES|n|N|no|No|NO|True|TRUE|False|FALSE|on|On|ON|off|Off|OFF|:/
      return false if value[/[a-zA-Z]/]
      return false if value[/[0-9]+\.[0-9]+\./]

      true
    end
  end
end

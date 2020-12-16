# frozen_string_literal: true

require_relative '../../../facter/config'

module Facter
  class FactGroups
    attr_accessor :groups_ttls
    attr_reader :groups, :block_list, :facts_ttls

    STRING_TO_SECONDS = { 'seconds' => 1, 'minutes' => 60, 'hours' => 3600, 'days' => 3600 * 24 }.freeze

    def initialize
      @groups = Facter::Config::FACT_GROUPS.dup
      load_groups
      load_groups_from_options
      load_facts_ttls

      # Reverse sort facts so that children have precedence when caching. eg: os.macosx vs os
      @facts_ttls = @facts_ttls.sort.reverse.to_h
    end

    # Breakes down blocked groups in blocked facts
    def blocked_facts
      fact_list = []

      @block_list.each do |group_name|
        facts_for_block = @groups[group_name]

        fact_list += facts_for_block || [group_name]
      end

      fact_list
    end

    # Get the group name a fact is part of
    def get_fact_group(fact_name)
      fact = get_fact(fact_name)
      return fact[:group] if fact

      # @groups.detect { |k, v| break k if Array(v).find { |f| fact_name =~ /^#{f}.*/ } }
      @groups.detect do |k, v|
        break k if Array(v).find { |f| fact_name.include?('.*') ? fact_name == f : fact_name =~ /^#{f}.*/ }
      end
    end

    # Get config ttls for a given group
    def get_group_ttls(group_name)
      return unless (ttls = @groups_ttls.find { |g| g[group_name] })

      ttls_to_seconds(ttls[group_name])
    end

    def get_fact(fact_name)
      return @facts_ttls[fact_name] if @facts_ttls[fact_name]

      result = @facts_ttls.select { |name, fact| break fact if fact_name =~ /^#{name}\..*/ }
      return nil if result == {}

      result
    end

    private

    def load_groups_from_options
      Options.external_dir.each do |dir|
        next unless Dir.exist?(dir)

        ext_facts = Dir.entries(dir)
        ext_facts.reject! { |ef| ef =~ /^(\.|\.\.)$/ }
        ext_facts.each do |ef|
          @groups[ef] = nil
        end
      end
    end

    def load_facts_ttls
      @facts_ttls ||= {}
      return if @groups_ttls == []

      @groups_ttls.reduce(:merge).each do |group, ttls|
        ttls = ttls_to_seconds(ttls)
        if @groups[group]
          @groups[group].each do |fact|
            if (@facts_ttls[fact] && @facts_ttls[fact][:ttls] < ttls) || @facts_ttls[fact].nil?
              @facts_ttls[fact] = { ttls: ttls, group: group }
            end
          end
        else
          @facts_ttls[group] = { ttls: ttls, group: group }
        end
      end
    end

    def load_groups
      config = ConfigReader.init(Options[:config])
      @block_list = config.block_list || []
      @groups_ttls = config.ttls || []
      @groups.merge!(config.fact_groups) if config.fact_groups
    end

    def ttls_to_seconds(ttls)
      duration, unit = ttls.split(' ', 2)
      duration.to_i * STRING_TO_SECONDS[unit]
    end
  end
end

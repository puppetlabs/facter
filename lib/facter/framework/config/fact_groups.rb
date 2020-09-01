# frozen_string_literal: true

module Facter
  class FactGroups
    attr_reader :groups, :block_list

    @groups_ttls = []

    STRING_TO_SECONDS = { 'seconds' => 1, 'minutes' => 60, 'hours' => 3600, 'days' => 3600 * 24 }.freeze

    def initialize(group_list_path = nil)
      default_path = File.join(File.dirname(__FILE__), '../../fact_groups.conf')
      @groups_file_path = group_list_path || default_path
      @groups ||= File.readable?(@groups_file_path) ? Hocon.load(@groups_file_path) : {}
      load_groups
      load_groups_from_options
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
      @groups.detect { |k, v| break k if Array(v).find { |f| fact_name =~ /^#{f}.*/ } }
    end

    # Get config ttls for a given group
    def get_group_ttls(group_name)
      return unless (ttls = @groups_ttls.find { |g| g[group_name] })

      ttls_to_seconds(ttls[group_name])
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

    def load_groups
      config = ConfigReader.init(Options[:config])
      @block_list = config.block_list || {}
      @groups_ttls = config.ttls || {}
      @groups.merge!(config.fact_groups) if config.fact_groups
    end

    def ttls_to_seconds(ttls)
      duration, unit = ttls.split(' ', 2)
      duration.to_i * STRING_TO_SECONDS[unit]
    end
  end
end

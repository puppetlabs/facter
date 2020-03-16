# frozen_string_literal: true

module Facter
  class BlockList
    include Singleton

    attr_reader :block_groups, :block_list

    def initialize(block_list_path = nil)
      @block_groups_file_path = block_list_path || File.join(ROOT_DIR, 'block_groups.conf')
      load_block_groups
    end

    # Breakes down blocked groups in blocked facts
    def blocked_facts
      fact_list = []

      @block_list.each do |group_name|
        facts_for_block = @block_groups[group_name]

        fact_list += facts_for_block || [group_name]
      end

      fact_list
    end

    private

    def load_block_groups
      @block_groups = File.readable?(@block_groups_file_path) ? Hocon.load(@block_groups_file_path) : {}
      options = Options.instance
      @block_list = ConfigReader.new(options[:config]).block_list || {}
    end
  end
end

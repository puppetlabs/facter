# frozen_string_literal: true

require 'facter/config'

module Facter
  class OsHierarchy
    def initialize
      @log = Log.new(self)
      @os_hierarchy = Facter::Config::OS_HIERARCHY
    end

    def construct_hierarchy(searched_os)
      return [] if searched_os.nil?

      searched_os = searched_os.to_s.capitalize
      if @os_hierarchy.nil?
        @log.debug("There is no os_hierarchy, will fall back to: #{searched_os}")
        return [searched_os]
      end

      @searched_path = []
      search(@os_hierarchy, searched_os, [])

      @searched_path.map { |os_name| os_name.to_s.capitalize }
    end

    private

    def search(json_data, searched_element, path)
      # we hit a dead end, the os was not found on this branch
      # and we cannot go deeper
      return unless json_data

      json_data.each do |tree_node|
        # we found the searched OS, so save the path from the tree
        @searched_path = path.dup << tree_node if tree_node == searched_element

        next unless tree_node.is_a?(Hash)

        tree_node.each do |k, v|
          return @searched_path = path.dup << k if k == searched_element

          search(v, searched_element, path << k)
          path.pop
        end
      end
    end
  end
end

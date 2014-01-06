module Facter
  module Util
    # A util module for facter containing helper methods
    module Values
      module_function

      # Perform a deep merge of two nested data structures.
      #
      # @param left [Object]
      # @param right [Object]
      # @param path [Array<String>] The traversal path followed when merging nested hashes
      #
      # @return [Object] The merged data structure.
      def deep_merge(left, right, path = [], &block)
        ret = nil

        if left.is_a? Hash and right.is_a? Hash
          ret = left.merge(right) do |key, left_val, right_val|
            path.push(key)
            merged = deep_merge(left_val, right_val, path)
            path.pop
            merged
          end
        elsif left.is_a? Array and right.is_a? Array
          ret = left.dup.concat(right)
        elsif right.nil?
          ret = left
        elsif left.nil?
          ret = right
        elsif left.nil? and right.nil?
          ret = nil
        else
          msg = "Cannot merge #{left.inspect}:#{left.class} and #{right.inspect}:#{right.class}"
          if not path.empty?
            msg << " at root"
            msg << path.map { |part| "[#{part.inspect}]" }.join
          end
          raise ArgumentError, msg
        end

        ret
      end

      def convert(value)
        value = value.to_s if value.is_a?(Symbol)
        value = value.downcase if value.is_a?(String)
        value
      end
    end
  end
end

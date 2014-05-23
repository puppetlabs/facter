module Facter
  module Util
    # A util module for facter containing helper methods
    module Values
      module_function

      class DeepFreezeError < StandardError; end

      # Duplicate and deeply freeze a given data structure
      #
      # @param value [Object] The structure to freeze
      # @return [void]
      def deep_freeze(value)
        case value
        when Numeric, Symbol, TrueClass, FalseClass, NilClass
          # These are immutable values, we can safely ignore them
          value
        when String
          value.dup.freeze
        when Array
          value.map do |entry|
            deep_freeze(entry)
          end.freeze
        when Hash
          value.inject({}) do |hash, (key, value)|
            hash[deep_freeze(key)] = deep_freeze(value)
            hash
          end.freeze
        else
          raise DeepFreezeError, "Cannot deep freeze #{value}:#{value.class}"
        end
      end

      class DeepMergeError < StandardError; end

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
          raise DeepMergeError, msg
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

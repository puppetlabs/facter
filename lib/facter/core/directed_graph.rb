require 'set'
require 'tsort'

module Facter
  module Core
    class DirectedGraph < Hash
      include TSort

      def acyclic?
        cycles.empty?
      end

      def cycles
        cycles = []
        each_strongly_connected_component do |component|
          cycles << component if component.size > 1
        end
        cycles
      end

      alias tsort_each_node each_key

      def tsort_each_child(node)
        fetch(node, []).each do |child|
          yield child
        end
      end

      def tsort
        missing = Set.new(self.values.flatten) - Set.new(self.keys)

        if not missing.empty?
          raise MissingVertex, "Cannot sort elements; cannot depend on missing elements #{missing.to_a}"
        end

        super

      rescue TSort::Cyclic
        raise CycleError, "Cannot sort elements; found the following cycles: #{cycles.inspect}"
      end

      class CycleError < StandardError; end
      class MissingVertex < StandardError; end
    end
  end
end

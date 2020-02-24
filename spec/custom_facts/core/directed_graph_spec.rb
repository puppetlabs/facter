# frozen_string_literal: true

require_relative '../../spec_helper_legacy'

describe LegacyFacter::Core::DirectedGraph do
  subject(:graph) { LegacyFacter::Core::DirectedGraph.new }

  describe 'detecting cycles' do
    it 'is acyclic if the graph is empty' do
      expect(graph).to be_acyclic
    end

    it 'is acyclic if the graph has no edges' do
      graph[:one] = []
      graph[:two] = []

      expect(graph).to be_acyclic
    end

    it 'is acyclic if a vertex has an edge to itself' do
      graph[:one] = [:one]
      expect(graph).to be_acyclic
    end

    it 'is acyclic if there are no loops in the graph' do
      graph[:one] = %i[two three]
      graph[:two] = [:four]
      graph[:three] = [:four]
      graph[:four] = []

      expect(graph).to be_acyclic
    end

    it 'is cyclic if there is a loop in the graph' do
      graph[:one] = [:two]
      graph[:two] = [:one]
      expect(graph).not_to be_acyclic
    end

    it 'can return the cycles in the graph' do
      graph[:one] = [:two]
      graph[:two] = [:one]

      graph[:three] = [:four]
      graph[:four] = [:three]

      first_cycle = graph.cycles.find { |cycle| cycle.include? :one }
      second_cycle = graph.cycles.find { |cycle| cycle.include? :three }

      expect(first_cycle).to include :two
      expect(second_cycle).to include :four
    end
  end

  describe 'sorting' do
    it 'returns the vertices in topologically sorted order' do
      graph[:one] = %i[two three]
      graph[:two] = [:three]
      graph[:three] = []
      expect(graph.tsort).to eq %i[three two one]
    end

    it 'raises an error if there is a cycle in the graph' do
      graph[:one] = [:two]
      graph[:two] = [:one]

      expect do
        graph.tsort
      end.to raise_error(LegacyFacter::Core::DirectedGraph::CycleError, /found the following cycles:/)
    end

    it 'raises an error if there is an edge to a non-existent vertex' do
      graph[:one] = %i[two three]
      graph[:two] = [:three]
      expect do
        graph.tsort
      end.to raise_error(LegacyFacter::Core::DirectedGraph::MissingVertex, /missing elements.*three/)
    end
  end
end

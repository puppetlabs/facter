require 'spec_helper'
require 'facter/core/directed_graph'

describe Facter::Core::DirectedGraph do
  subject(:graph) { described_class.new }

  describe "detecting cycles" do
    it "is acyclic if the graph is empty" do
      expect(graph).to be_acyclic
    end

    it "is acyclic if the graph has no edges" do
      graph[:one] = []
      graph[:two] = []

      expect(graph).to be_acyclic
    end

    it "is acyclic if a vertex has an edge to itself" do
      graph[:one] = [:one]
      expect(graph).to be_acyclic
    end

    it "is acyclic if there are no loops in the graph" do
      graph[:one] = [:two, :three]
      graph[:two] = [:four]
      graph[:three] = [:four]
      graph[:four] = []

      expect(graph).to be_acyclic
    end

    it "is cyclic if there is a loop in the graph" do
      graph[:one] = [:two]
      graph[:two] = [:one]
      expect(graph).to_not be_acyclic
    end

    it "can return the cycles in the graph" do
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

  describe "sorting" do
    it "returns the vertices in topologically sorted order" do
      graph[:one] = [:two, :three]
      graph[:two] = [:three]
      graph[:three] = []
      expect(graph.tsort).to eq [:three, :two, :one]
    end

    it "raises an error if there is a cycle in the graph" do
      graph[:one] = [:two]
      graph[:two] = [:one]

      expect {
        graph.tsort
      }.to raise_error(Facter::Core::DirectedGraph::CycleError, /found the following cycles:/)
    end

    it "raises an error if there is an edge to a non-existent vertex" do
      graph[:one] = [:two, :three]
      graph[:two] = [:three]
      expect {
        graph.tsort
      }.to raise_error(Facter::Core::DirectedGraph::MissingVertex, /missing elements.*three/)
    end
  end
end

# frozen_string_literal: true

describe Facter::Macosx::ProcessorsCount do
  describe '#call_the_resolver' do
    it 'returns processors fact' do
      value = '4'

      expected_fact = double(Facter::ResolvedFact, name: 'processors.count', value: value)
      allow(Facter::Resolvers::Macosx::Processors).to receive(:resolve).with(:logicalcount).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('processors.count', value).and_return(expected_fact)

      fact = Facter::Macosx::ProcessorsCount.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end

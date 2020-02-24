# frozen_string_literal: true

describe Facter::El::ProcessorsPhysicalcount do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      value = '1'

      expected_fact = double(Facter::ResolvedFact, name: 'processors.physicalcount', value: value)
      allow(Facter::Resolvers::Linux::Processors).to receive(:resolve).with(:physical_count).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('processors.physicalcount', value).and_return(expected_fact)

      fact = Facter::El::ProcessorsPhysicalcount.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end

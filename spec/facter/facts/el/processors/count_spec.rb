# frozen_string_literal: true

describe Facter::El::ProcessorsCount do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      value = '4'

      expected_fact = double(Facter::ResolvedFact, name: 'processors.count', value: value)
      allow(Facter::Resolvers::Linux::Processors).to receive(:resolve).with(:processors).and_return(value)
      allow(Facter::ResolvedFact).to receive(:new).with('processors.count', value).and_return(expected_fact)

      fact = Facter::El::ProcessorsCount.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end

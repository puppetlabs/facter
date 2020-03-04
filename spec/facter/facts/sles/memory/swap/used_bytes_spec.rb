# frozen_string_literal: true

describe Facts::Sles::Memory::Swap::UsedBytes do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.swap.used_bytes', value: '1342128128')
      allow(Facter::Resolvers::Linux::Memory).to receive(:resolve)
        .with(:used_bytes)
        .and_return('1342128128')
      allow(Facter::ResolvedFact).to receive(:new)
        .with('memory.swap.used_bytes', '1342128128')
        .and_return(expected_fact)

      fact = Facts::Sles::Memory::Swap::UsedBytes.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end

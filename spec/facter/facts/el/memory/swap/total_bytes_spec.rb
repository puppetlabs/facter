# frozen_string_literal: true

describe Facts::El::Memory::Swap::TotalBytes do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.swap.total_bytes', value: 'value')
      allow(Facter::Resolvers::Linux::Memory).to receive(:resolve).with(:swap_total).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('memory.swap.total_bytes', 'value').and_return(expected_fact)

      fact = Facts::El::Memory::Swap::TotalBytes.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end

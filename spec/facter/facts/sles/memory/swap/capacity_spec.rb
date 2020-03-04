# frozen_string_literal: true

describe Facts::Sles::Memory::Swap::Capacity do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.swap.capacity', value: '0.00%')
      allow(Facter::Resolvers::Linux::Memory).to receive(:resolve).with(:swap_capacity).and_return('0.00%')
      allow(Facter::ResolvedFact).to receive(:new).with('memory.swap.capacity', '0.00%').and_return(expected_fact)

      fact = Facts::Sles::Memory::Swap::Capacity.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end

# frozen_string_literal: true

describe Facts::Windows::Memory::System::Capacity do
  describe '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.system.capacity', value: 'value')
      allow(Facter::Resolvers::Memory).to receive(:resolve).with(:capacity).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('memory.system.capacity', 'value').and_return(expected_fact)

      fact = Facts::Windows::Memory::System::Capacity.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end

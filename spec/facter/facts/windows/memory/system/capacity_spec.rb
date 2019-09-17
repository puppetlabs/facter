# frozen_string_literal: true

describe 'Windows MemorySystemCapacity' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.system.capacity', value: 'value')
      allow(MemoryResolver).to receive(:resolve).with(:capacity).and_return('value')
      allow(Facter::ResolvedFact).to receive(:new).with('memory.system.capacity', 'value').and_return(expected_fact)

      fact = Facter::Windows::MemorySystemCapacity.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end

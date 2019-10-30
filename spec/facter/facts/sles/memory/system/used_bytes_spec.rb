# frozen_string_literal: true

describe 'Sles MemorySystemUsedBytes' do
  context '#call_the_resolver' do
    it 'returns a fact' do
      expected_fact = double(Facter::ResolvedFact, name: 'memory.system.used_bytes', value: 1_342_128_128)
      allow(Facter::Resolvers::Linux::Memory).to receive(:resolve).with(:used_bytes).and_return(1_342_128_128)
      allow(Facter::ResolvedFact).to receive(:new)
        .with('memory.system.used_bytes', 1_342_128_128)
        .and_return(expected_fact)

      fact = Facter::Sles::MemorySystemUsedBytes.new
      expect(fact.call_the_resolver).to eq(expected_fact)
    end
  end
end
